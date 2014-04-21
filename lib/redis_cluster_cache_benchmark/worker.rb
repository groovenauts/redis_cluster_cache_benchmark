require "redis_cluster_cache_benchmark"

require 'logger'

require 'redis'
require 'redis-sentinel'
require 'redis_wmrs'

module RedisClusterCacheBenchmark
  class Worker
    def initialize(options)
      @options = options
      @repeat = (options[:repeat] || 1).to_i
      @worker_no = (options[:worker_no] || 0).to_i
      @classname = load_option(:classname, "RedisClusterCacheBenchmark::MemoryStorage")
      @log_path = load_option(:log_path)
      @config_path = load_option(:config_path)
      @scenario = load_option(:scenario)
    end

    def load_option(key, default_value = nil)
      r = @options[key]
      r = nil if r && r.empty?
      r || default_value
    end

    def logger
      unless @logger
        @logger = Logger.new(@log_path || $stdout)
        @logger.level = Logger::INFO
      end
      @logger
    end

    def new_client
      config =
        @config_path ? YAML.load_file_with_erb(@config_path) :
        {host: "127.0.0.1", port: 6379}
      case @classname
      when 'Redis', 'RedisWmrs' then
        klass = Object.const_get(@classname)
        original = klass.new(config)
        original.client.logger = logger
        return LoggingClient.new(original, logger)
      when "RedisClusterCacheBenchmark::MemoryStorage" then
        original = RedisClusterCacheBenchmark::MemoryStorage.new
        original.logger = logger
        return LoggingClient.new(original, logger)
      else
        raise "Unknown classname: #{@classname.inspect}"
      end
    end

    MEGA = 1_000_000

    def run
      $client = new_client
      len = @repeat.to_s.length
      logger.info("[RSS] starting  #{@worker_no}: %d KB" % `ps -o rss= -p #{Process.pid}`.to_i)
      @repeat.times do |idx|
        t0 = Time.now.to_f
        begin
          load(@scenario)
        ensure
          logger.info("No.%3d scenario %*d/%*d finished [SCENARIO] %6.9f microsec" % [@worker_no, len, idx + 1, len, @repeat, (Time.now.to_f - t0) * MEGA])
        end
      end
      logger.info("[RSS] completed #{@worker_no}: %d KB" % `ps -o rss= -p #{Process.pid}`.to_i)
    end

  end
end

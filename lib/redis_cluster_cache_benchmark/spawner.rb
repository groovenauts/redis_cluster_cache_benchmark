require 'redis_cluster_cache_benchmark'

module RedisClusterCacheBenchmark
  class Spawner

    def initialize(options)
      @process_number = options.delete(:process).to_i
      @process_number = 5 if @process_number < 1
      @options = options
    end

    def run
STDOUT.puts("#{__FILE__}##{__LINE__}")
      options = @options.each_with_object({}) do |(k,v), d|
        d["RCCB_#{k.upcase}"] = v.to_s
      end
      cmd = File.expand_path("../../../bin/worker", __FILE__)
STDOUT.puts("#{__FILE__}##{__LINE__} cmd: #{cmd} @process_number: #{@process_number}")
      @process_number.times do |idx|
        options["RCCB_WORKER_NO"] = (idx + 1).to_s
        Kernel.spawn(options, cmd)
      end
    end

  end
end

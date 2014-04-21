require 'redis_cluster_cache_benchmark'

require 'fileutils'
require 'time'
require 'socket'

module RedisClusterCacheBenchmark
  class Spawner

    def initialize(options)
      @base_name = "%s_%s_p%d_r%d" % [options[:classname] || 'Memory', options[:name], options[:process], options[:repeat]]
      @process_number = options.delete(:process).to_i
      @process_number = 5 if @process_number < 1
      @options = options
    end

    def run
      start_time = Time.now
      FileUtils.mkdir_p(@options[:log_dir])
      redis_server_starting_rss = process_rss("redis-server")
      options = @options.each_with_object({}) do |(k,v), d|
        unless v.to_s.empty?
          d["RCCB_#{k.upcase}"] = v.to_s
        end
      end
      cmd = File.expand_path("../../../bin/worker", __FILE__)
      log_path_base = File.expand_path("#{@base_name}.log", @options[:log_dir])
      system("rm #{log_path_base}.*")
      pids = []
      @process_number.times do |idx|
        if log_path_base
          options["RCCB_LOG_PATH"] = "#{log_path_base}.#{idx + 1}"
        end
        options["RCCB_WORKER_NO"] = (idx + 1).to_s
        pids << Kernel.spawn(options, cmd)
      end
      pids.each do |pid|
        begin
          Process.waitpid(pid)
        rescue Errno::ECHILD => e
          $stderr.puts("WARN  [#{e.class}] #{e.message}")
        end
      end
      complete_time = Time.now
      redis_server_completed_rss = process_rss("redis-server")
      system("cat #{log_path_base}.* > #{log_path_base}")
      system("grep \"\\[GET\\]\" #{log_path_base} > #{log_path_base}.get")
      system("grep \"\\[SET\\]\" #{log_path_base} > #{log_path_base}.set")
      system("grep \"\\[RSS\\] starting\" #{log_path_base} > #{log_path_base}.rss_starting")
      system("grep \"\\[RSS\\] completed\" #{log_path_base} > #{log_path_base}.rss_completed")

      result = {
        "environment" => {
          "hostname" => Socket.gethostname,
        },
        "summary" => {
          "started_at"   =>start_time.iso8601,
          "completed_at" => complete_time.iso8601,
          "time_sec"     => complete_time - start_time,
        },
        "workers" => {
          "GET_microsec" => calc_array_summary("#{log_path_base}.get", / ([\d\.]+) microsec\Z/),
          "SET_microsec" => calc_array_summary("#{log_path_base}.set", / ([\d\.]+) microsec\Z/),
          "RSS_KB_when_start"    => calc_array_summary("#{log_path_base}.rss_starting" , / \d+: (\d+) KB\Z/),
          "RSS_KB_when_complete" => calc_array_summary("#{log_path_base}.rss_completed", / \d+: (\d+) KB\Z/),
        },
        "redis_server" => {
          "RSS_KB_when_start"    => redis_server_starting_rss,
          "RSS_KB_when_complete" => redis_server_completed_rss,
        }
      }
      File.open(File.expand_path("#{@base_name}.yml", @options[:log_dir]), "w") do |f|
        YAML.dump(result, f)
      end
      system("rm #{log_path_base}.*")
    end

    def calc_array_summary(path, pattern)
      values = []
      File.open(path) do |f|
        f.each_line do |line|
          values.push line.scan(pattern).flatten.first.to_f
        end
      end
      Summary.new(values).to_hash
    end

    def process_rss(command_name)
      r = `ps ax -o pid,command | grep #{command_name} | grep -v grep\\ #{command_name}`
      return 0 if r.nil? || r.empty?
      pid = r.strip.split(/\s+/, 2).first.to_i
      `ps -o rss= -p #{pid}`.to_i
    end

  end
end

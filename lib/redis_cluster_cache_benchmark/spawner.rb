require 'redis_cluster_cache_benchmark'

module RedisClusterCacheBenchmark
  class Spawner

    def initialize(options)
      @process_number = options.delete(:process).to_i
      @process_number = 5 if @process_number < 1
      @options = options
    end

    def run
      options = @options.each_with_object({}) do |(k,v), d|
        unless v.to_s.empty?
          d["RCCB_#{k.upcase}"] = v.to_s
        end
      end
      cmd = File.expand_path("../../../bin/worker", __FILE__)
      log_path_base = options["RCCB_LOG_PATH"] ? options["RCCB_LOG_PATH"].dup : nil
      if log_path_base
        system("rm #{log_path_base}.*")
      end
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
      if log_path_base
        system("cat #{log_path_base}.* > #{log_path_base}")
        system("grep get #{log_path_base} > #{log_path_base}.get")
        system("grep set #{log_path_base} > #{log_path_base}.set")
        # dir = File.dirname(log_path_base)
        # system("ls -la #{dir}")
        calc_summary("#{log_path_base}.get", "get")
        calc_summary("#{log_path_base}.set", "set")
      end
    end

    def calc_summary(path, caption = nil)
      values = []
      File.open(path) do |f|
        f.each_line do |line|
          values.push line.scan(/ ([\d\.]+) microsec\Z/).flatten.first.to_f
        end
      end
      summary = Summary.new(values)
      $stdout.puts
      $stdout.puts caption || path
      $stdout.puts "cnt: #{summary[:cnt]} times"
      fmt = "%3s: %9.3f microsec"
      %w[avg max 99 95 90 80 50 min].each do |k|
        $stdout.puts fmt % [k, summary[k].to_f]
      end
    end

  end
end

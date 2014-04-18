require 'redis_cluster_cache_benchmark'

module RedisClusterCacheBenchmark
  class Spawner

    def initialize(options)
      @process_number = options.delete(:process).to_i
      @process_number = 5 if @process_number < 1
      @options = options
    end

    def run
      redis_server_starting_rss = process_rss("redis-server")
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
      redis_server_completed_rss = process_rss("redis-server")
      if log_path_base
        system("cat #{log_path_base}.* > #{log_path_base}")
        system("grep \[GET\] #{log_path_base} > #{log_path_base}.get")
        system("grep \[SET\] #{log_path_base} > #{log_path_base}.set")
        system("grep \"\\[RSS\\] starting\" #{log_path_base} > #{log_path_base}.rss_starting")
        system("grep \"\\[RSS\\] completed\" #{log_path_base} > #{log_path_base}.rss_completed")
        # dir = File.dirname(log_path_base)
        # system("ls -la #{dir}")
        calc_array_summary("#{log_path_base}.get", "get", / ([\d\.]+) microsec\Z/, "%3s: %9.3f microsec")
        calc_array_summary("#{log_path_base}.set", "set", / ([\d\.]+) microsec\Z/, "%3s: %9.3f microsec")
        calc_array_summary("#{log_path_base}.rss_starting", "memory before start", / \d+: (\d+) KB\Z/, "%3s: %d KB")
        calc_array_summary("#{log_path_base}.rss_completed", "memory after complete", / \d+: (\d+) KB\Z/, "%3s: %d KB")
      end
      $stdout.puts
      $stdout.puts "redis-server"
      $stdout.puts "starting : #{redis_server_starting_rss} KB"
      $stdout.puts "completed: #{redis_server_completed_rss} KB"
    end

    def calc_array_summary(path, caption, pattern, fmt)
      values = []
      File.open(path) do |f|
        f.each_line do |line|
          values.push line.scan(pattern).flatten.first.to_f
        end
      end
      summary = Summary.new(values)
      $stdout.puts
      $stdout.puts caption
      $stdout.puts "cnt: #{summary[:cnt]}"
      %w[sum avg max 99 95 90 80 50 min].each do |k|
        $stdout.puts fmt % [k, summary[k].to_f]
      end
    end

    def process_rss(command_name)
      r = `ps a -o pid,command | grep #{command_name} | grep -v grep\\ #{command_name}`
      return 0 if r.nil? || r.empty?
      pid = r.strip.split(/\s+/, 2).first.to_i
      `ps -o rss= -p #{pid}`.to_i
    end

  end
end

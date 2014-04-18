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

      File.open(File.expand_path("#{@base_name}.md", @options[:log_dir]), "w") do |f|
        f.puts "hostname    : #{Socket.gethostname}"
        f.puts "started at  : #{start_time.iso8601}"
        f.puts "completed at: #{complete_time.iso8601}"
        f.puts "time: #{complete_time - start_time} sec"

        calc_array_summary(f, "#{log_path_base}.get", "[GET]", / ([\d\.]+) microsec\Z/, "%3s: %9.3f microsec")
        calc_array_summary(f, "#{log_path_base}.set", "[SET]", / ([\d\.]+) microsec\Z/, "%3s: %9.3f microsec")
        calc_array_summary(f, "#{log_path_base}.rss_starting" , "memory before start"  , / \d+: (\d+) KB\Z/, "%3s: %d KB")
        calc_array_summary(f, "#{log_path_base}.rss_completed", "memory after complete", / \d+: (\d+) KB\Z/, "%3s: %d KB")
        f.puts
        f.puts "redis-server"
        f.puts "starting : #{redis_server_starting_rss} KB"
        f.puts "completed: #{redis_server_completed_rss} KB"
      end
      system("rm #{log_path_base}.*")
    end

    def calc_array_summary(f, path, caption, pattern, fmt)
      values = []
      File.open(path) do |f|
        f.each_line do |line|
          values.push line.scan(pattern).flatten.first.to_f
        end
      end
      summary = Summary.new(values)
      f.puts
      f.puts caption
      f.puts "cnt: #{summary[:cnt]}"
      %w[sum avg max 99 95 90 80 50 min].each do |k|
        f.puts fmt % [k, summary[k].to_f]
      end
    end

    def process_rss(command_name)
      r = `ps ax -o pid,command | grep #{command_name} | grep -v grep\\ #{command_name}`
      return 0 if r.nil? || r.empty?
      pid = r.strip.split(/\s+/, 2).first.to_i
      `ps -o rss= -p #{pid}`.to_i
    end

  end
end

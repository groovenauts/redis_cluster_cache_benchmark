require 'redis_cluster_cache_benchmark'

require 'optparse'

options = {
  process: 10,
  repeat: 1,
  scenario: nil,
  classname: nil,
  log_path: nil,
}

OptionParser.new{|opt|
  opt.version = RedisClusterCacheBenchmark::VERSION
  opt.on("-p", "--process=#{options[:process]}"    , "number of process"    ){|v| options[:process] = v.to_i }
  opt.on("-r", "--repeat=#{options[:repeat]}"      , "number of repeat"     ){|v| options[:repeat] = v.to_i }
  opt.on("-s", "--scenario=#{options[:scenario]}"  , "path to scenario file"){|v| options[:scenario] = v }
  opt.on("-C", "--classname=#{options[:classname]}", "client class name"    ){|v| options[:classname] = v }
  opt.on("-c", "--config=#{options[:config_path]}" , "path to config file"  ){|v| options[:config_path] = v }
  opt.on("-l", "--log-path=#{options[:log_path]}"  , "path to log file"     ){|v| options[:log_path] = v }
}.parse!

RedisClusterCacheBenchmark::Spawner.new(options).run

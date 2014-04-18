require 'redis_cluster_cache_benchmark'

require 'optparse'

options = {
  name: nil,
  process: 10,
  repeat: 1,
  scenario: nil,
  classname: nil,
  log_dir: File.expand_path("./log"),
}

OptionParser.new{|opt|
  opt.version = RedisClusterCacheBenchmark::VERSION
  opt.on("-N", "--name=#{options[:name]}"          , "name of test pattern" ){|v| options[:name] = v }
  opt.on("-p", "--process=#{options[:process]}"    , "number of process"    ){|v| options[:process] = v.to_i }
  opt.on("-r", "--repeat=#{options[:repeat]}"      , "number of repeat"     ){|v| options[:repeat] = v.to_i }
  opt.on("-s", "--scenario=#{options[:scenario]}"  , "path to scenario file"){|v| options[:scenario] = v }
  opt.on("-C", "--classname=#{options[:classname]}", "client class name"    ){|v| options[:classname] = v }
  opt.on("-c", "--config=#{options[:config_path]}" , "path to config file"  ){|v| options[:config_path] = v }
  opt.on("-l", "--log-dir=#{options[:log_dir]}"    , "path to log file directory"){|v| options[:log_dir] = v }
}.parse!

raise "--name must be given." unless options[:name]

RedisClusterCacheBenchmark::Spawner.new(options).run

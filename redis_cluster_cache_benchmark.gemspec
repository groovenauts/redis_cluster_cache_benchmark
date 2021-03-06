# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redis_cluster_cache_benchmark/version'

Gem::Specification.new do |spec|
  spec.name          = "redis_cluster_cache_benchmark"
  spec.version       = RedisClusterCacheBenchmark::VERSION
  spec.authors       = ["akima"]
  spec.email         = ["akm2000@gmail.com"]
  spec.summary       = %q{redis benchmark as a cache}
  spec.description   = %q{redis benchmark as a cache}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "redis"
  spec.add_runtime_dependency "redis-sentinel"
  spec.add_runtime_dependency "redis_wmrs"
  spec.add_runtime_dependency "hiredis"

  spec.add_runtime_dependency "tengine_support", "~> 1.2.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end

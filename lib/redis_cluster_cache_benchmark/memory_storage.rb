require "redis_cluster_cache_benchmark"

module RedisClusterCacheBenchmark
  class MemoryStorage
    attr_accessor :logger

    def initialize(*)
      @impl = {}
    end

    def get(key)
      @impl[key]
    end

    def set(key, value, options = {})
      @impl[key] = value
    end

  end
end

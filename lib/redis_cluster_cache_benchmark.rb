require "redis_cluster_cache_benchmark/version"

module RedisClusterCacheBenchmark
  autoload :Spawner      , "redis_cluster_cache_benchmark/spawner"
  autoload :Worker       , "redis_cluster_cache_benchmark/worker"
  autoload :LoggingClient, "redis_cluster_cache_benchmark/logging_client"
  autoload :MemoryStorage, "redis_cluster_cache_benchmark/memory_storage"
  autoload :Summary      , "redis_cluster_cache_benchmark/summary"
end

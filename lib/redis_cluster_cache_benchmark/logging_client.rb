require "redis_cluster_cache_benchmark"

module RedisClusterCacheBenchmark
  class LoggingClient
    def initialize(impl, logger)
      @impl = impl
      @logger = logger
    end

    def get(key)
      __logging__("[GET]"){ @impl.get(key) }
    end

    def set(key, value, options = {})
      __logging__("[SET]"){ @impl.set(key, value, options) }
    end


    def get_object(bucket, key, options = {})
      __logging__("[GET]"){ @impl.get_object(bucket, key, options) }
    end
    def store(bucket, key, value)
      bucket = @impl.bucket(bucket)
      obj = bucket.new(key)
      obj.data = value
      __logging__("[SET]"){ obj.store }
    end

    private

    MEGA = 1_000_000

    def __logging__(msg = nil)
      t0 = Time.now.to_f
      begin
        return yield
      ensure
        @logger.info("%s %6.9f microsec" % [msg, (Time.now.to_f - t0) * MEGA])
      end
    end

  end
end

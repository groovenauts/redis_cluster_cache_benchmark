# -*- coding: utf-8 -*-
module RedisClusterCacheBenchmark
  class Summary
    include Enumerable

    DEFAULT_POSITIONS = [99, 95, 90, 80, 50].freeze

    # @param [Array<Numeric>] values 整数あるいは実数の配列
    def initialize(values, positions = DEFAULT_POSITIONS)
      values = values.sort
      cnt = values.length
      sum = values.inject(:+)
      @hash = {
        cnt: cnt,
        sum: sum,
        avg: sum / cnt,
        min: values.first,
        max: values.last,
      }
      positions.each do |pos|
        idx = (cnt * pos / 100).round
        @hash[pos.to_s.to_sym] = values[idx]
      end
    end

    def to_hash
      @hash.dup
    end

    def each(&block)
      @hash.each(&block)
    end

    def [](key)
      @hash[key.to_s.to_sym]
    end
  end
end

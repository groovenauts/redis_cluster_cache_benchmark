# RedisClusterCacheBenchmark

This is a benchmark application for some redis clients used as cache.

These client libraries are available:

* [Memory cache](https://github.com/groovenauts/redis_cluster_cache_benchmark/blob/master/lib/redis_cluster_cache_benchmark/memory_storage.rb)
* [redis-rb](https://github.com/redis/redis-rb)
* [redis-sentinal](https://github.com/flyerhzm/redis-sentinel)
* [redis_wmrs](https://github.com/groovenauts/redis_wmrs)

## Installation

install this application on each server to run redis clients.

```
$ git clone https://github.com/groovenauts/redis_cluster_cache_benchmark.git
```

## Usage

```
$ cd path/to/redis_cluster_cache_benchmark
$ bin/redis_cluster_cache_benchmark --help
Usage: redis_cluster_cache_benchmark [options]
    -N, --name=                      name of test pattern
    -p, --process=10                 number of process
    -r, --repeat=1                   number of repeat
    -s, --scenario=                  path to scenario file
    -C, --classname=                 client class name
    -c, --config=                    path to config file
    -l/Users/akima/groovenauts/redis_cluster_cache_benchmark/log,
        --log-dir                    path to log file directory
```

### With memory cache

```
bin/redis_cluster_cache_benchmark -s examples/w1r10.rb -r 10000 -p 10 -N simple
```

### With redis-rb (and sentinel)

```
bin/redis_cluster_cache_benchmark -s examples/w1r10.rb -r 10000 -p 10 -N simple -C Redis -c examples/redis_with_sentinel.yml
```


### With redis_wmrs (and sentinel)

```
bin/redis_cluster_cache_benchmark -s examples/w1r10.rb -r 10000 -p 10 -N simple -C RedisWmrs -c examples/redis_with_sentinel.yml
```

### Riak

```
bin/redis_cluster_cache_benchmark -s examples/w1r10_riak.rb -N riak_devrel -C Riak::Client -c examples/riak_devrel_5.yml
```



## Contributing

1. Fork it ( http://github.com/groovenauts/redis_cluster_cache_benchmark/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# RedisClusterCacheBenchmark

This is a benchmark application for some redis clients.

These client libraries are available:

* [redis-rb](https://github.com/redis/redis-rb)
* [redis-sentinal](https://github.com/flyerhzm/redis-sentinel)
* [redis-wmrs](https://github.com/groovenauts/redis_wmrs)

## Installation

install this application on each server to run redis clients.

```
$ git clone https://github.com/groovenauts/redis_cluster_cache_benchmark.git
```

## Usage

```
$ cd path/to/redis_cluster_cache_benchmark
$ bin/redis_cluster_cache_benchmark --help                                                                                                                                                                                                                                                      [~/groovenauts/redis_cluster_cache_benchmark]
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


## Contributing

1. Fork it ( http://github.com/<my-github-username>/redis_cluster_cache_benchmark/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

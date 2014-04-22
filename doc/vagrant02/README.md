## Patterns

| Name         | Cache place | Write     | Read        |
| ------------ |-------------|-----------|-------------|
| Memory cache | Memory      | memory    | memory      |
| Redis        | Redis       | to master | from master |
| RedisWmrs    | Redis       | to master | from slave  |

## Result

* 10 VMs on iMac, 10 worker processes run on each VM.
* the scenario is just GET or SET. https://github.com/groovenauts/redis_cluster_cache_benchmark/blob/1bed988b555b0f07cfb82298fe0010d94c41f3cb/examples/w1r10.rb
* 1 test repeats the scenario 10,000 times.
* Master redis node is on apisrv01.

| Name         | server   | time(sec) | GET avg(ms) | SET avg(ms) | SET cnt  | SCENARIO avg(ms) | worker total(KB) | redis-sever(KB) | total(KB) |
| ------------ |:--------:| ---------:| -----------:| -----------:| --------:| ----------------:|-----------------:| ---------------:|----------:|
| Memory cache | apisrv01 | 291       |  0.259      |  0.704      | 63,342   | 27.441           | 471,556          |  -              | 471,556   |
| redis-rb     | apisrv01 | 283.902   | 26.864      | 30.505      |  1,094   | 27.883           | 122,328          | 139,424         | 261,752   |
| redis-rb     | apisrv05 | 326.010   | 30.985      | 36.397      |  1,039   | 32.100           | 120,936          |  73,020         | 193,956   |
| redis_wmrs   | apisrv01 | 203.257   | 11.980      | 24.614      |  9,580   | 19.508           | 129,660          | 137,568         | 267,228   |
| redis_wmrs   | apisrv05 | 178.052   |  7.187      | 47.862      |  4,372   | 16.444           | 124,924          |  73,020         | 197,944   |

RedisWmrs works faster than Redis and Memory cache.

For more detail https://github.com/groovenauts/redis_cluster_cache_benchmark/tree/master/doc/vagrant02



## How to collect log and summaries

Execute this command on each VM after execute benchmark.

```
$ tar zcf `hostname`_log-20140421_1218.tgz log/
```

Download tarballs from each VM to local PC.

```
$ for i in {'01'..'10'}; do scp apisrv${i}:~/redis_cluster_cache_benchmark/apisrv${i}_log-20140421_1218.tgz doc/vagrant02/; done
$ cd doc/vagrant02
$ for i in {'01'..'10'}; do tar zxf apisrv${i}_log-20140421_1218.tgz && mv log apisrv${i}_log; done
```


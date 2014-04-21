## Result

* 10 VMs on iMac, 10 worker process run on each VM.
* the scenario is just GET or SET.
* 1 test repeats the scenario 10,000 times.
* Master redis node is on apisrv01.

| Name         | server   | time(sec) | GET avg(ms) | SET avg(ms) | SCENARIO avg(ms) | worker total(KB) | redis-sever(KB) | total(KB) |
| ------------ |:--------:| ---------:| -----------:| -----------:| ----------------:|-----------------:| ---------------:|----------:|
| Memory cache | apisrv01 | 291       |  0.259      |  0.704      | 27.441           | 471,556          |  -              | 471,556   |
| Redis        | apisrv01 | 283.902   | 26.864      | 30.505      | 27.883           | 122,328          | 139,424         | 261,752   |
| Redis        | apisrv05 | 326.010   | 30.985      | 36.397      | 32.100           | 120,936          |  73,020         | 193,956   |
| RedisWmrs    | apisrv01 | 203.257   | 11.980      | 24.614      | 19.508           | 129,660          | 137,568         | 267,228   |
| RedisWmrs    | apisrv05 | 178.052   |  7.187      | 47.862      | 16.444           | 124,924          |  73,020         | 197,944   |

RedisWmrs works fater than Redis and Memory cache.

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

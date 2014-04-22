## パターン

| Name         | Cache place | Write     | Read        |
| ------------ |-------------|-----------|-------------|
| Memory cache | Memory      | memory    | memory      |
| redis-rb     | Redis       | to master | from master |
| redis_wmrs   | Redis       | to master | from slave  |

## 結果

* iMac(Late 2012, 2.9 GHz Intel Core i5, 32 GB 1600 MHz DDR3)上の10台のVM(CentOS release 6.4 (Final))
* ruby 2.0.0p353 (2013-11-22 revision 43784) [x86_64-linux]
* シナリオはランダムなキーでGETして、あればそれを返し、なければ値を作ってSETするというもの。
    * https://github.com/groovenauts/redis_cluster_cache_benchmark/blob/1bed988b555b0f07cfb82298fe0010d94c41f3cb/examples/w1r10.rb
* 1回のテストでは各プロセスごとにシナリオを10,000回実行する。
* redisのマスタノードはapisrv01で動いており、それ以外のサーバではそのマスタのslaveが動いている。

| Name         | server   | time(sec) | GET avg(ms) | SET avg(ms) | SET cnt  | SCENARIO avg(ms) | worker total(KB) | redis-sever(KB) | total(KB) |
| ------------ |:--------:| ---------:| -----------:| -----------:| --------:| ----------------:|-----------------:| ---------------:|----------:|
| Memory cache | apisrv01 | 291       |  0.259      |  0.704      | 63,342   | 27.441           | 471,556          |  -              | 471,556   |
| redis-rb     | apisrv01 | 283.902   | 26.864      | 30.505      |  1,094   | 27.883           | 122,328          | 139,424         | 261,752   |
| redis-rb     | apisrv05 | 326.010   | 30.985      | 36.397      |  1,039   | 32.100           | 120,936          |  73,020         | 193,956   |
| redis_wmrs   | apisrv01 | 203.257   | 11.980      | 24.614      |  9,580   | 19.508           | 129,660          | 137,568         | 267,228   |
| redis_wmrs   | apisrv05 | 178.052   |  7.187      | 47.862      |  4,372   | 16.444           | 124,924          |  73,020         | 197,944   |

redis_wmrsがMemory cacheやredis-rbよりも早い。


## 考察

### メモリ使用量

メモリの使用量はメモリキャッシュと、redis-rb/redis_wmrsで異なる。

これはMemory cacheが各プロセスでメモリを使用してキャッシュを作っているのに対して、redis-rb/redis_wmrsではそれぞれのサーバ毎に
redisのノードを起動しredis上にデータを保持し、各プロセス上では保持しないためである。

もし、プロセス数が少ない、あるいはキャッシュするデータの量が少ない場合であれば、Memory cacheの方が有利かもしれないが、
後述の理由から単純なMmoery cacheは使うべきではない。


### CPU負荷

redis-rbでは、全てのプロセスがSETもGETもマスタノードであるapisrv01に接続するため、マスタノードにCPU負荷が集中する。

redis_wmrsは、redis-rbの拡張だが、SETはマスタノードに、GETはできるだけローカルのノードに対して行うため、
redis-rbのパターンよりもCPU負荷が一箇所に集中しない。


### SETの回数

redis_wmrsはredis-rbのパターンよりもSETを行う回数が多い。

実行するシナリオで作成するキーは0から10,000までの整数を文字列にしたものなので、10台のVMで実行するとそれぞれ1,000回前後
SETが実行されるはずであり、redis-rbではそのような値が計測できた。

しかし、redis_wmrsではそれを大きく上回る4,500回近くSETが実行されている。

これはSETによりマスタノードにデータが登録されてから、スレーブノードにレプリケーションされるまでの間に、そのキーに対する
GETが行われデータが取得できなかった回数が多いということを示している。

SETとGETを別のノードに対して行うのであれば、このタイムラグを取り除くことは難しい。タイムラグを0にするのであればロックの
ような仕組みが必要になり、ロックを導入すると効率的にSETとGETを行うことが難しくなる。

redis_wmrsを使うのであれば、SETとSETする値を取得するための処理の回数がredis-rbのように単純ではないことを理解しておく必要がある。




### 単純なMemory cacheを使うべきでない理由

1. キャッシュをクリアする仕組みがない

キャッシュをクリアできないと緊急的にデータを変更した場合にキャッシュに変更を反映することができない。

2. メモリを使い果たす可能性

古いデータを削除するなどの仕組みによってメモリを使い果たさないようにしないとアプリケーションがメモリを使い果たしてしまう可能性がある。





## ログの集め方

下記のコマンドを各サーバで実行する

```
$ tar zcf `hostname`_log-20140421_1218.tgz log/
```

以下のコマンドで各サーバからローカルのPCにコピーする

```
$ for i in {'01'..'10'}; do scp apisrv${i}:~/redis_cluster_cache_benchmark/apisrv${i}_log-20140421_1218.tgz doc/vagrant02/; done
$ cd doc/vagrant02
$ for i in {'01'..'10'}; do tar zxf apisrv${i}_log-20140421_1218.tgz && mv log apisrv${i}_log; done
```


# How to achieve read-write separation using redis replication with Sentinels & the go-redis library?
## Problem
Want to read from replicas and only write to the master, to reduce master loads.
## Solution
Create read-only clients using `NewFailOverClient(opt)` with `opt.SlaveOnly` set to `true`. 

IMPORTANT NOTE:
If this field is `false`, go-redis will only choose the **MASTER**. Too bad!

https://github.com/go-redis/redis/blob/cae67723092cac2cb441bc87044ab9edacb2484d/sentinel.go#L227
```go
if failover.opt.SlaveOnly {
    addr, err = failover.RandomSlaveAddr(ctx)
} else {
    addr, err = failover.MasterAddr(ctx)
    if err == nil {
        failover.trySwitchMaster(ctx, addr)
    }
}
```
If set to `true`, go-redis will find a random slave **through Sentinel** each time, which perfectly suits our purpose.
## Intricacies
### Question
SlaveOnly: If there're many replicas, it will randomly choose one. Does the "choose" action happen only when the Client sets up or it happens for every command (like GET)? 
### Answer 
The "choose" action only happens on Client creation. After that, all commands are directed to the same replica.
### Test1
```go
c := NewFailoverClient()
err := c.FlushAll(c.Context()).Err()
if err != nil {
    panic(err)
}
err = c.Set(c.Context(), "k1", "v1", 0).Err()
if err != nil {
    panic(err)
}

roc := NewFailoverReadOnlyClient()
for i := 0; i < 3; i++ {
    res, err := roc.Get(roc.Context(), "k1").Result()
    if err != nil {
        panic(err)
    }
    fmt.Println(res)
}
```
Listen for GET commands on each replica using

`redis-cli -p 6380 -a password monitor | grep "get"`
#### Result
All directed to one replica.
### Test2
```go
c := NewFailoverClient()
err := c.FlushAll(c.Context()).Err()
if err != nil {
    panic(err)
}
err = c.Set(c.Context(), "k1", "v1", 0).Err()
if err != nil {
    panic(err)
}
for i := 0; i < 3; i++ {
    roc := NewFailoverReadOnlyClient()
    res, err := roc.Get(roc.Context(), "k1").Result()
    if err != nil {
        panic(err)
    }
    fmt.Println(res)
}
```
#### Result
Requests are directed to different replicas.

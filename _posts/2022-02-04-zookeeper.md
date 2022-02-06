---
title: 浅谈zookeeper
categories:
  - Blog
tags:
  - Distributed Systems
  - Zookeeper
---

# 什么是zookeeper，为什么要有zookeeper

http://nil.csail.mit.edu/6.824/2021/papers/zookeeper.pdf

In this paper, we describe ZooKeeper, a service for **coordinating processes of distributed applications**.

# zookeeper的特点

## raft的问题

一个词：**性能**。

在raft中，读和写都必须go thorough the leader（clients only interact with the leader）。它的坏处很显然：scalability不行。随着机器增加，同步一个写操作会花费越来越多的时间。

另外，如果全都向master读，master的性能会受到很大影响。

## 读写分离

这个时候当然想到读写分离，上面两个问题就都解决了。

### 读写分离的问题：consistency

显然slave可能没那么快同步到master的数据。这时会出现一些问题：

1. 自己读不到自己的write。
2. 自己两次read的结果不同。(unrepeatable read)
3. 如果中途switch replicas，可能产生Back-in-time reads。

## 因此ZooKeeper无法保证consistency(linearizability)

它只保证下面两个性质：

<img src="/assets/zoo/guarantees.png" alt="mr1" height="150"/>

简单解释：

1. 不同用户的写操作，ZK会choose an order（represented by **zxid** - 你可以理解为raft里的log index），并保证按zxid的顺序执行。
2. 同一用户的读&写操作，ZK保证操作按用户指定的顺序执行。换句话说，同一用户看到的**自己的**操作都是符合逻辑的。当然，read可能会block（当你read的server还没更新自己前面的write时）。

In contrast, ZK不能guarantee自己能及时read到其他人update的信息。也就是可能read stale data.

总结：ZK

# zookeeper结构 / API

树形文件结构（why？因为某些操作，比如后面提到的check group membership，可以利用文件的阶级性）

watch: 调API的时候如果设置了watch flag，那么当相应文件（第一次）发生变化时就会收到通知。

API:

<img src="/assets/zoo/API.png" alt="mr1" height="250"/>

# 所以为什么zookeeper可以作为coordination service？

利用”文件“储存配置信息。ZK的API设计非常concurrency-oriented，所以比较好coordinate。

# 配置同步

要获取某文件`pathname`的最新配置，只要getData(pathname)并设置watch = true。这样后面也能收到更新。

# Check Group Membership

建立一个空节点parent，代表整个group。

每当一个进程/服务器想加入该group，就在group下面创建一个孩子。你可以自由命名，或者让zookeeper帮你命名（加一个sequential flag就可以了）。

要获取group信息，只要列出parent节点的孩子就可以了。

## Leader Switch

// paper 2.3

利用一个”ready“ file。

master刚被选上的时候，delete "ready" file，然后开始配置。配置完毕后create "ready" file。followers只有看到"ready" file之后才能开始配置。

根据之前的FIFO ordering guarantee，看到"ready" file的时候就说明master已经配置完毕了。

**exception: follower checked "ready" file before master deletion**

可以通过加watch来避免这种情况。具体可以看 http://nil.csail.mit.edu/6.824/2021/notes/l-zookeeper.txt

## Counter（test-and-modify）

// paper 2.3

要做一个counter，我可以在某文件储存cnt，然后用ZK的API模拟test-and-modify。

test: getData

modify: setData

```
while (true) {
	val, version = getData(path);
	if (setData(path, val + 1, version))
		break;
}
```

## Lock（利用文件存在性）

// paper 2.4

```
acquire():
  while true:
    if create("lf", ephemeral=true), success
    if exists("lf", watch=true)
      wait for notification

release(): (voluntarily or session timeout)
  delete("lf")
```

# Barrier

Barrier的语义是**所有进程reach barrier之后才能继续执行**。

ZK使用一个znode来做barrier。到达barrier的进程会创建一个znode的子节点，并设置watch。

当子节点数量达到threshold时就启动所有进程。为了防止”check子节点数量时有进程已经结束“的情况，最后一个到达barrier的进程会创建一个特殊的节点。其他进程只要看到特殊节点就可以启动了。


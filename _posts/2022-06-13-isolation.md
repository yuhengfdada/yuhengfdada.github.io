---
title: Isolation Level (MySQL & Postgres)
categories:
  - Blog
tags:
  - Database
---

# Isolation level与事务中的问题

这个应该已经很熟了。

RU, RC, RR, Serializable

Dirty read （读到其他事务**未提交**的更改）,

Non-repeatable read（读到其他事务提交或未提交的更改）,

Phantom read（条件查询的结果受到其他事务的影响，产生不一致）。

以上是课堂内容，实际上还有一个

Serialization anomaly（执行结果不符合serializable要求，即任何串行的执行顺序都不可能导致该结果）。

举个例子：比如说一个accounts表，有owner和balance两列。

执行`insert into accounts (owner, balance) select 'sum', sum(balance) from accounts;`

在RR级别下由于是快照，两个事务同时进行该操作的话会产生两个balance一样的sum行，而如果是串行操作不可能出现此情况。

# 理论上的对应关系

RU：所有问题都有

RC：避免Dirty Read

RR：还避免了NR Read

Serializable：还避免了Phantom Read

# MySQL

默认RR

RU：所有问题都有

RC：避免Dirty Read

RR：还避免了NonRepeatable Read和Phantom Read（间隙锁）

Serializable：还避免了Serialization anomaly（通过锁实现，表现为死锁并拒绝其他并行事务）

# Postgres

默认RC

RU：相当于RC

RC：避免Dirty Read

RR：还避免了NonRepeatable Read和Phantom Read

Serializable：还避免了Serialization anomaly（通过判断依赖实现，表现为暂时拒绝其他并行事务，当其他事务commit后重试可以成功）

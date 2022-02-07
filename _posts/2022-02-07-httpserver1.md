---
title: TinyWebServer研究（1）
categories:
  - Blog
tags:
  - Network Programming
  - Linux
---

打算把[TinyWebServer](https://github.com/qinguoyi/TinyWebServer)写一遍。

目标：写一个epoll LT，线程池，定时处理非活动连接的web服务器。

附加功能：ET，日志，连接MySql数据库。

# Step 1. 简单epoll服务器

https://yuhengfdada.github.io/blog/server/#server-v5-epoll

在这个的基础上写得更优雅一些。

## http_conn类，buffer机制 

每个http_conn对象对应一个连接。对象内储存了该连接对应的client socket fd，用于唯一标识该client。整个类有一个static int来储存服务器的epfd。有了它就可以操纵epoll事件了。

当新的connection到来，除了register epoll event之外，还要init一个http_conn对象。

http_conn对象中有一个buffer和一个pointer，pointer指向未占用部分的开始。

每次收到client socket的readable事件，先调用相应http_conn对象的read_once()方法把socket全给读到对象中的buffer里。先判断是不是EOF，然后交给线程池处理刚刚读到的内容。

## EPOLLONESHOT

实现的时候遇到一个问题：在LT模式，分配线程handle之后，主线程很快又会调用epoll_wait()。但如果此时子线程还没开始读socket / 没读完socket，epoll_wait()又会返回同一个socket的readable事件，主线程又会分配一个子线程去处理**同一个**fd。这显然8太好。

即使是ET模式，短时间内client发过来好几次数据时也会有多线程处理同一fd的情况。

可以在注册事件时加入`EPOLLONESHOT` flag解决。它的语义是：该fd触发一次事件之后就再也不会触发了。所以同时只会有一个线程在处理这个fd。

使用`EPOLLONESHOT`的注意点：线程处理完fd之后，需要再次启用该fd上的通知时，要手动使用EPOLL_CTL_MOD并加上`EPOLLONESHOT`。

https://man7.org/linux/man-pages/man2/epoll_ctl.2.html

# Step 2. 线程池

在线程池init的时候，调用多次pthread_create()，全都执行一个函数：worker()。worker()之后调用run()。

run()会一直while loop，直到事件队列中出现一个http_conn对象。此时的http_conn对象中的buffer刚刚读取完信息，处于待处理状态。run()会调用该http_conn对象的process()函数来处理。

## 同步事件队列

加入队列：调用append()函数。在将http_conn对象放入队列的同时将信号量++。

取出事件：将信号量--。

对队列的操作必须加锁。


---
title: 大杂烩：Service层，开闭原则，分库分表
categories:
  - Blog
tags:
  - Software Engineering
  - Database
---

# 为什么要有service层？

在阿里的时候也经常看见，有一个XXService接口然后有一个XXServiceImpl。

网上看到service层就是业务逻辑的接口。

事实上阿里对外暴露的接口一般叫XXBizService。

service层的好处是接口与实现分离。我觉得这样代码确实干净了不少。

# 开闭原则

啥叫“对扩展开放，对改动关闭”？

我知道改动是不要改源代码，不然可能导致服务崩溃。

“扩展”的意思是：现在要加一个新功能，如何不破坏原来的功能。

常见的做法是通过接口抽象出通用的功能，然后通过增加不同的实现类来实现新功能。

比如设计一个MessageService。这个Message可以是Email也可以是WeChat啥的。

如果一开始考虑到了Message的不同形式，就可以把Message抽象成一个接口，MessageService只要hold一个Message成员变量并调用成员变量的sendMessage()方法就可以了。如果要增加一种Message，只要新增一个继承Message接口的类，比如WeChatMessage，即可。

https://zhuanlan.zhihu.com/p/24269134

https://blog.csdn.net/zhengzhb/article/details/7296944

# 分库分表

https://zhuanlan.zhihu.com/p/136963357

## 分表

水平分：一张表的行分一些出来。

* RANGE: 直接切。缺点是新数据一般比较hot，导致比较新的分表负载较大。
* HASH: hash切。解决了RANGE的缺点，但是机器加入就要重新hash，很烦。
* 一致性哈希：环状，解决了前面的问题。
  * 解决哈希不均衡：对每个node，在环上设置很多虚拟node。

垂直分：一张表的字段分一些出来。

* 表中的字段较多，一般将不常用的、 数据较大、长度较长的拆分到“扩展表“。一般情况加表的字段可能有几百列，此时是按照字段进行数竖直切。注意垂直分是列多的情况。

## 分库

水平分：把单张表水平切到很多库上，比较麻烦。

垂直分：根据业务切到不同的库上，比如订单系统和用户系统的表分别存在不同的库上。（sharding key）

## 主从复制

6.824应该学过，由于一般读操作远远多于写操作，所以搞一个slave和很多master，写操作往master写，读操作从slave读。master和slave之间保持同步。

![master](/assets/potpourri/master.png)


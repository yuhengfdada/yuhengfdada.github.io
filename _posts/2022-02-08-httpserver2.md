---
title: TinyWebServer研究（2）
categories:
  - Blog
tags:
  - Network Programming
  - Linux
---

昨天是做出来一个可以打印出client发过来的信息的一个服务器。今天做一下接到读请求->读相应文件->返回符合http格式的返回报文。

主要还是理清楚整个流程。理清楚就好写了。

![1](/assets/httpserver2/1.png)

![2](/assets/httpserver2/2.png)

今天的知识点：

`stat()`函数可以返回文件的各种信息。比如我们关心的size。

`mmap()`可以把文件映射到内存里。老朋友了。

`struct iovec`包含一个指针和一个整数，分别表示一段内存地址的开头 与 要读取/写入的长度。

它和`writev()`配合使用，可以将好几个`iovec`对应的内存依次全部写到指定的fd中。在httpserver中，第一个iovec对应的是状态行 + 请求头，第二个iovec对应的是GET请求的文件。



整个流程中只有收到“readable”事件时才需要交线程池处理，而就是这一部分处理干了大部分事情。

这一部分处理（`process`函数）：读请求，parse请求，根据请求内容向http_conn对象中填入各种信息（比如文件pointer，构建请求头放在m_write_buffer中...）。最后注册一个EPOLLOUT事件并重置EPOLLONESHOT，以备接下来的write使用。

然后收到EPOLLOUT事件：只要调用writev()把请求头+文件内容塞到socket里就行了。

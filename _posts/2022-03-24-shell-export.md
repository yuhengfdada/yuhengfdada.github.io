---
title: shell中的“冒号”，export，source
categories:
  - Blog
tags:
  - Shell
---

冒号 = 路径分隔符

* 比如说/bin/aaa:/bin/bbb就可以表示并存的两个路径。

export [变量]=[值]

* 可以设置环境变量的值。

source [文件名]

* 将文件内容当做shell指令执行。通常用来执行刚修改过的初始化文件（例如zshrc）。

以下命令在PATH中加入了JAVA_HOME，并且将PATH和JAVA_HOME放入./zshrc文件中。

```bash
JAVA_HOME=/usr/local/....
export JAVA_HOME
export PATH=$PATH:$JAVA_HOME
source ~/.zshrc
```




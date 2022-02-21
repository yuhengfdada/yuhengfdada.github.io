---
title: 浅谈虚拟化
categories:
  - Blog
tags:
  - Virtualization
  - OS
---

https://inst.eecs.berkeley.edu/~cs162/su20/static/lectures/26.pdf

# Why VMs?

如果说以前的应用只是一个executable，那么现代应用则是一个复杂的整体。所以我们要虚拟出所有运行环境才可以。

# How to Virtualize?

Software Emulation: QEMU

* User software emulates the behavior of every single instruction
* Caveat: TOO slow

Modern: Execute the guest code DIRECTLY

条件：same ISA (like x86)

# Challenges in Virtualization

如果我们想在Host上直接执行Guest的指令，可能有如下的问题：

![challenges](/assets/vir/challenges.png)

## VMM

![vmm](/assets/vir/vmm.png)

VMM是一个Guest OS和Host OS的中间件。大多数之前提到的challenges可以通过VMM介入来解决。

## Priviledged Instructions

Guest OS只是Host上的一个普通进程，所以guest的priviledged instructions不能直接在host上执行。

解决：guest的priv.instr.s会trap到VMM，然后VMM模拟出来。

## I/O

Guest与IO device之间的交互也是通过VMM来完成的。

## Address Translation

![va](/assets/vir/va.png)

![shadow](/assets/vir/shadow.png)

## Interrupts and Traps

trap to VMM.

# Hypervisor

我们平常接触的都是Hosted VM，也就是有一个主系统，在上面跑VM。

还有一种常用的结构叫Hypervisor，直接跑在hardware上，然后上面跑多个并行的VM。

![hyp](/assets/vir/hyp.png)

---
title: lc经典题及思路
categories:
  - Blog
tags:
  - LeetCode
---

国内厂感觉考经典题的比较多，特别是那种经典的hard，没做过绝对想不到怎么做。遵从“核心题刷到会为止”的思想，特开一帖记录一下我做了很多次都8会的题。

# [4. 寻找两个正序数组的中位数](https://leetcode-cn.com/problems/median-of-two-sorted-arrays/)

找中位数是一个特殊的“找第k个数”问题。

**重点思想：**每次排除一些“必然不是第k个数”的数。找两个数组中分别第k / 2个数，小的那个及左边肯定必不是。

# 单调栈

任务：“找左边第一个比自己小的数”

从左到右用**升序**单调栈。对于一个新元素，单调栈操作会pop掉所有左边比它大的元素，剩下在栈顶的就是左边第一个比它小的元素了。

[84. 柱状图中最大的矩形](https://leetcode-cn.com/problems/largest-rectangle-in-histogram/)

[85. 最大矩形](https://leetcode-cn.com/problems/maximal-rectangle/)

最大矩形这题的妙处是把矩形的每个列转换成一个“柱状图”。

# 表达式evaluation

栈。大部分可以用双栈：操作数栈+运算符栈。

# DP

很多hard还是DP。无奈了。

## 线性DP

#### [32. 最长有效括号](https://leetcode-cn.com/problems/longest-valid-parentheses/) 基本的线性DP



## 表达式匹配

这类问题的思路是f(i, j)表示s[1:i]与p[1:j]是否匹配。

#### [10. 正则表达式匹配](https://leetcode-cn.com/problems/regular-expression-matching/) wtf真的难

#### [44. 通配符匹配](https://leetcode-cn.com/problems/wildcard-matching/) 

---
title: 一道lc字符串题（通配符）
categories:
  - Blog
tags:
  - LeetCode
---

在看微软面经，看到这么一题：

实现一个数据结构，以字符串数组作为构造参数，实现一个方法，传入参数是字符串，返回字符串数组中是否存在一个字符串与传入字符串有且仅有一个字符不一致，其他字符一致且位置一致。

# 第0步：暴力

显然是O(mn)。

# 第一步：reduce问题复杂度

问题：多次query，判断一个固定字符串集合中是否存在满足条件的字符串。

小问题：给定**两个**字符串，判断是否满足条件？

这个小问题答案必然是O(m)，因此不能在“比较方式”上下功夫。

# 第二步：利用多余条件

小问题中，给定的两个字符串是没有条件的。但是原问题中，有一部分字符串是“预先输入”的。所以只剩下“预处理”一条路了...

# 第三步：brainstorm - 如何预处理

可以想到一个query O(1)的超级暴力解法：对于每个输入字符串，将它的每个字符分别改成不同的字符，然后把所有这样的组合加入到哈希表中。query直接查询是否存在就可以了。

预处理复杂度为O(字符space * mn)。如果是ascii的话其实就还好？常数也就几十，如果query很多的话就不太行。但是空间复杂度也是O(字符space * mn)，也许太大了。

那么如果字符space很大的话，怎么办？

# 终极解法：通配符

对于每个字符串，将每个位置的字符改成“*”并加入哈希表。

每次query，将待query字符串每个位置的字符也改成“*”。对这m个字符串匹配一遍哈希表就行了。

预处理O(mn) 查询O(m)


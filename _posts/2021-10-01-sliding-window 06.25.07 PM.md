---
title: "Array - 3 - Sliding Window"
categories:
  - Blog
tags:
  - LeetCode
  - Array
---

数组第三课，滑动窗口。

# [209. 长度最小的子数组](https://leetcode-cn.com/problems/minimum-size-subarray-sum/)

这次是另一种双指针玩法：区间。

本算法的精髓：**当本窗口元素之和>=target时，将左边指针向右移动**。

先想一下暴力解法：对所有的起始index i，枚举区间[i, j]，第一个>=target的区间即为以i开始的长度最小的子数组。

因此本算法与暴力算法的唯一不同就是：每个i不用全部枚举一遍了。

如何做到这点？只需要保证：该算法中，任意窗口[i, j]中，不存在i<=k<j, that sum([i, k]) >= target.

证明：使用反证法。如果存在这样的k，那么在快指针走到j之前，[i, k]就已经被筛选出来了。

```python
def minSubArrayLen(self, target: int, nums: List[int]) -> int:
    left = 0
    res = len(nums) + 1
    for right in range(len(nums)): 
        while sum(nums[left:right+1]) >= target:
            res = min(res, right + 1 - left)
            left += 1
            if left > right:
                break
        # else continue
    return 0 if res == len(nums) + 1 else res
```

小结：这个方法如果没见过确实想不到。时间复杂度: O(n), since 每个元素被快指针慢指针各扫过一遍。

另外一种O(nlogn)的解法是暴力解法的一种优化。事实上这种连续子数组问题前缀和出现的概率挺高。

和暴力解法一样先确定起始下标i，但j是在右边二分查找得出的。

# [904. 水果成篮](https://leetcode-cn.com/problems/fruit-into-baskets/)

一样的策略，条件变成窗口中水果的种类数。

```python
def totalFruit(self, fruits: List[int]) -> int:
    left = 0
    best = 0
    typeCountMap = {}
    for right in range(len(fruits)):
        lfruit = fruits[left]
        rfruit = fruits[right]
        if rfruit not in typeCountMap:
            typeCountMap[rfruit] = 1
        else:
            typeCountMap[rfruit] += 1

        while len(typeCountMap) >= 3:
            lfruit = fruits[left]
            typeCountMap[lfruit] -= 1
            if typeCountMap[lfruit] == 0:
                typeCountMap.pop(lfruit)
            left += 1
        else:
            best = max(best, right - left + 1)
    return best
```

# [76. 最小覆盖子串](https://leetcode-cn.com/problems/minimum-window-substring/)

滑动窗口如何滑动，没有思考正确。我想维护窗口内永远满足条件这一不变量，但这和滑动窗口的主旨不符。

实际上解法和209非常类似：**符合条件时移慢指针，不符合条件时移快指针**。唯一的区别是条件不同而已。

```python
def contains(self, numChars, tHash):
    for c in tHash:
        if c not in numChars or numChars[c] < tHash[c]:
            return False
    return True
def minWindow(self, s: str, t: str) -> str:
    left = 0
    bestStr = ""
    best = len(s) + 1
    numChars = {}
    tHash = {}
    # initialize tHash
    for c in t:
        if c not in tHash:
            tHash[c] = 1
        else:
            tHash[c] += 1 
    for right in range(len(s)):
        if s[right] not in numChars:
            numChars[s[right]] = 1
        else:
            numChars[s[right]] += 1
        while self.contains(numChars, tHash):
            if right - left + 1 < best:
                bestStr = s[left:right+1]
                best = right - left + 1
            numChars[s[left]] -= 1
            if numChars[s[left]] == 0:
                numChars.pop(s[left])
            left += 1
    return bestStr
```

# 总结

谨记**符合条件时移慢指针，不符合条件时移快指针**这一技巧。

我总是犯的一个失误是：移慢指针的时候应该是`while`（因为可能移了之后窗口元素还是符合条件），不能写成`if`。

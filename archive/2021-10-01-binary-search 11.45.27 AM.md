---
title: "Array - 1 - Binary Search"
categories:
  - Blog
tags:
  - LeetCode
  - Array
---

数组第一课，二分查找。

#  Core

```python
def search(self, nums: List[int], target: int) -> int:
    left = 0
    right = len(nums) - 1
    while left <= right:
        mid = (left + right) // 2
        if nums[mid] == target:
            return mid
        if nums[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    return -1
```

我个人喜欢这么写（CLRS）。

#  [701](https://leetcode-cn.com/problems/binary-search/)

最基础的二分查找，很快就过了。

# [35. 搜索插入位置](https://leetcode-cn.com/problems/search-insert-position/)

转换为查找第一个>=target的元素。

```python
def search(self, nums: List[int], target: int) -> int:
    left = 0
    right = len(nums) - 1
    ans = len(nums)
    while left <= right:
        mid = (left + right) // 2
        if nums[mid] >= target:
            ans = mid
            right = mid - 1
        else:
            left = mid + 1
    return ans
```

#  [34.在排序数组中查找元素的第一个和最后一个位置](https://leetcode-cn.com/problems/find-first-and-last-position-of-element-in-sorted-array/)

和上一题思路类似，第一个位置即第一个>=target的元素，最后一个位置即（第一个>target的元素位置 - 1）.

```python
def helper(self, nums, target, equals):
    left = 0
    right = len(nums) - 1
    ans = right + 1
    while left <= right:
        mid = (left + right) // 2
        if (nums[mid] >= target and equals) or (not equals and nums[mid] > target):
            ans = mid
            right = mid - 1
        else:
            left = mid + 1
    return ans

def searchRange(self, nums: List[int], target: int) -> List[int]:
    left = self.helper(nums, target, True)
    right = self.helper(nums, target, False) - 1
    if left > right or nums[left] != target or nums[right] != target:
        return [-1, -1]
    return [left, right]
```

这里要特别注意ans的初始值是尾后元素，因为如果整个数组都没有比target大的元素，这时`第一个>=target的元素`的语义应该是数组后的第一个元素。

还有最后的if判断`if left > right or nums[left] != target or nums[right] != target`, 技巧是根据`left`和`right`的语义，如果target在数组中，这三种情况都是不可能发生的。

# [69.sqrt(x)](https://leetcode-cn.com/problems/sqrtx/)

最重要的还是思路，将问题转化成寻找最大的k, 使k^2 <= x. 换句话说就是[0,x]中最后一个使k^2 <= x的元素。和34的解法完全一致。

```python
def mySqrt(self, x: int) -> int:
    left = 0
    right = x
    ans = 0
    while left <= right:
        mid = (left + right) // 2
        if mid * mid <= x:
            ans = mid
            left = mid + 1
        else:
            right = mid - 1
    return ans
```

#  [367.有效的完全平方数](https://leetcode-cn.com/problems/valid-perfect-square/)

比69简单，思路是找k^2==x。

#  总结

二分查找的题目关键点是将问题转换为能够使用二分查找解决的问题。

能被二分查找解决的特点：

1. 输入集有序。
2. 诸如第一个>=x的数，最后一个<=x的数。

二分查找就是一个不断“逼近”的过程。
---
title: 217. Contains Duplicate
author: nguyentp
date: 2024-07-27
tags: [leetcode]
render_with_liquid: false
---

# [Problem understanding](https://leetcode.com/problems/contains-duplicate/)

```
Input: nums = [1,2,3,1]
Output: true
```

- 1 appears twice -> return True.
- Base on the constraint, number could be negative or zero.

# Edge case

- empty list: False
- single element: False
- `[1, 1, 1, 1]` input: True

# Solution

1. 2 nested loop. Time N^2, Space N.
2. Hash: `seen` hash table to check whether we have seen a number. Then go through each number, if we see it the first time, put it into the `seen` hash table. Otherwise, there is duplicate. Time: N, Space: N.

# Implement

```
class Solution(object):
    def containsDuplicate(self, nums):
        """
        :type nums: List[int]
        :rtype: bool
        """
        if len(nums) <= 1:
            return False
        
        seen = set()
        for n in nums:
            if n in seen:
                return True
            seen.add(n)
        return False
```

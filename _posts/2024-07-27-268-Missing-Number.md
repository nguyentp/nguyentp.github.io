---
title: 268. Missing Number
author: nguyentp
date: 2024-07-27
tags: [leetcode]
render_with_liquid: false
---

# [Problem understanding](https://leetcode.com/problems/missing-number/description/)

``
Input: nums = [3,0,1]
Output: 2
```

- `N = 3`, then valid number should be `0, 1, 2, 3`. 2 is the missing number.
- Base on the constraint, smallest number is 0 and largest is N. Smallest input is single element. In that case, `[0] or [1]`.

# Edge case

- `[0]`: return 1
- `[1]`: return 0
- `0, 1, 2`: All number are in order, return 3
- `1, 2, 3`: return 0
- `3, 2, 1`: return 0

# Solution

1. Go through each number, check if that number is NOT in the all valid numbers. We use a hash table to store all valid numbers to speed up the checking. Time: N b/c loop through the input, Space: N to store all valid numbers.
2. Hint: `distinct numbers in the range [0, n]`, For list [3,0,1], if we put number to its correct index, each number will have its place in the list. E.g. `3, 0, 1`, 0 will be at index 0, 1 is at index 1, 3 is at index 2 (3 is special case). So at the index 2, the value is 3, so the missing number is 2. We go through each number, if current number is not standing in its correct index, swap it to correct index.

- For example: `3, 0, 1`

```
[3, 0, 1]
 i  -> skip, as we cannot swap 3 to index 3

 [3, 0, 1]
     i  -> swap 0 to index 0
     
 [0, 3, 1]
     i  -> skip, as we cannot swap 3 to index 3

 [0, 3, 1]
        i  -> swap 1 to index 1

 [0, 1, 3]
        i  -> skip, as we cannot swap 3 to index 3

Finnaly, loop through the list, we see that at index 2, we found a missing number b/c value at index 2 is not 2. 2 is the answer.
```

- Edge case: when input has perfect order, such as `0, 1, 2`, in that case, we will return N.

# Implement

```
class Solution(object):
    def missingNumber(self, nums):
        """
        :type nums: List[int]
        :rtype: int
        """
        n = len(nums)
        i = 0
        while i < n:
            if nums[i] == n or nums[i] == i:
                i += 1
            else:
                nums[nums[i]], nums[i] = nums[i], nums[nums[i]]

        for i in range(len(nums)):
            if nums[i] != i:
                return i
        return n
```

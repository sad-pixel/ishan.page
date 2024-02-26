---
title: "Calculating The Number Of Digits In A Power Of 2"
date: 2024-02-25
slug: power-digits-log-formula-trick
tags: ["math", "python", "logarithm"]
description: Understanding Logarithms Better With This Cool Trick
math: true
---

I want to share something cool I learned about logarithms. If you've found logarithms a bit tricky, like I did, you'll love this trick!

It's a neat way to see logarithms in action and made things click for me.

---

Someone asked me how I would go about approximating the number of digits in $2^{32}$. 

I found [this discussion](https://math.stackexchange.com/questions/1693073/how-many-digits-are-in-the-integer-representation-of-2-to-the-30th-power) on StackExchange. To quote the top answer:

> A general formula for the number of digits of any power of 2 can be found using the value of the base-10 logarithm of 2.   
> 
> The number of digits in 2k is   
> $1 + \lfloor k \cdot \log_{10}(2) \rfloor$  

The trick uses a fundamental property of logarithms and shows how they relate to the scale of numbers in different bases, particularly base 10 (since we're interested in the number of digits). Let's try to break it down:

The logarithm of a number is the exponent to which another fixed number, the base, must be raised to produce that number. 

In this case, we're dealing with $log_{10}$, which tells us how many times we must multiply 10 to get our number. 

Given $2^k$, where $k$ is an integer, we want to find out how many digits this number has. 

To do this, we can take the base 10 logarithm of $2^k$, expressed as $\log_{10}(2^k)$. 

Using the property of logarithms that allows us to bring the exponent to the front, we get:

$\log_{10}(2^k) = k \cdot \log_{10}(2)$

The value of $\log_{10}(2)$ is approximately $0.30$. This tells us how many times 10 must be multiplied to reach the base 2. 

When we multiply this value by $k$, we get a sense of how large $2^k$ is in terms of its place in the base-10 system.

The resulting value $k \cdot \log_{10}(2)$ gives us a decimal number that correlates with the magnitude of $2^k$ in base 10. 

However, this doesn't directly tell us the number of digits. We still need to floor it and add 1.

The logarithm gives us the "order of magnitude" of our number in base 10.

For example, $\log_{10}(100) = 2$, meaning $10^2 = 100$ has 3 digits. 

The log tells us it's in the hundreds place, but we know that anything in the hundreds (from 100 to 999) has 3 digits.

By adding 1 to the result, we essentially round up from this "order of magnitude" to the actual number of digits. 

We have to take the floor because the result isn't always clean. 

Consider the cases of 553 and 999:

$\log_{10}(553) = 2.472$    
$\lfloor\log_{10}(553)\rfloor = 2$    
$\lfloor\log_{10}(553)\rfloor + 1 = 3$

$\log_{10}(999) = 2.999$   
$\lfloor\log_{10}(999)\rfloor = 2$    
$\lfloor\log_{10}(999)\rfloor + 1 = 3$

This works because the number of digits is always one more than its logarithm's floor value for numbers in base 10.

The formula $\(1 + k \cdot \log_{10}(2)\)$ therefore calculates the number of digits in $2^k$ by using the log to find its order of magnitude in base 10, and then adjusting for the fact that the number of digits is one more than that magnitude. 

Let's try to verify the result:

We'll calculate the number of digits in two ways using a Python script, with the first method being the formula, and the other by converting $2^k$ to a string and getting its length. Finally we'll compare the results and note the differences.

```python
import math

results = [(k, 1 + math.floor(k * math.log10(2)), len(str(2**k))) for k in range(1, 501)]
mismatches = [result for result in results if result[1] != result[2]]
print(mismatches[:1])
# []
```

This verification code loops over $k$ from 1 to 500. Since there is nothing in the mismatches array, it shows that the formula $1 + \lfloor k \cdot \log_{10}(2) \rfloor$ correctly gives the number of digits in $2^k$ for every value of \$k$ in this range. 
---
title: "\"Why is 'a' = 97 anyway?..."
description: The massive ramifications of a seemingly minor fact
tags: [history]
date: 2023-11-14
slug: 2023-11-14-why-is-a-97-anyway
draft: true 
---

...It makes absolutely no sense!", is what I thought to myself as I sat in that 9th grade computer science class. 

My mind churned at the thought of having to memorize this little factoid, along with the other one that 'A' = 65, because it absolutely would be asked on the exam. Oh man, CS was supposed to be about computers and doing things with them and stuff, not memorizing stupid numbers!

"Why do they care about this inane piece of trivia?"

Many years later, I now know that this "little factoid" actually has huge ramifications, and I wish someone had explained it to me back then. I'm going to try to put it all into context.

## An Aside On Binary

Before we dive in I'd like to take a moment to discuss why we even need these letters to be numbers. You can skip this portion if you're already familiar with the topic.

The letters are numbers because computers only understand numbers. But not numbers in the way we think of them, per se-- 

We think in base 10, meaning, we have 10 different numbers:    
0, 1, 2, 3, 4, 5, 6, 7, 8, 9.

Let's imagine a hypothetical scenario. We want to write twelve, which is one more than ten, the number of digits we have. How do we do that?

We write is as 12. 

1 x 10 + 2 x 1

How about a bigger number, like one hundred and fifty three?

(1 x 100) + (5 x 10) + (3 x 1)

Do you see the pattern?

We are multiplying each digit with a power of 10 (recall from high school, 10^0 = 1). 

So, 153 is actually

(1 x 10^2 )+ (5 x 10^1) + (3 x 10^0)

## The Story of ASCII

ASCII stands for American Standard Code for Information Interchange. It is a standard encoding format for electronic communication between computers. ASCII codes represent text in computers, telecommunications equipment, and other devices. 

ASCII was first developed in the 1960s as a common format, but it did not see widespread usage until 1981, when IBM used it in its first PC.  Before ASCII, there were different encoding schemes for different machines and applications, such as ITA 2, FIELDATA, EBCDIC, Baudot code, etc. These schemes were incompatible with each other and caused problems when transferring data across different systems. 

For example, ITA 2 was a five-bit code that could only represent 32 characters. It was used for telegraphy and teletype machines. FIELDATA was a six-bit code that could represent 64 characters. It was used by the US military for data processing. EBCDIC was an eight-bit code that could represent 256 characters. It was used by IBM mainframes and other systems. Baudot code was another five-bit code that could represent 32 characters. It was used for teleprinters and radio communication. 

As you can see, these encoding schemes had different bit lengths, character sets, and applications. They were not compatible with each other and could not be easily converted or exchanged. This created a lot of confusion and inefficiency in data communication.

ASCII solved this problem by creating a standard seven-bit code that could represent 128 characters, including 95 printable characters and 33 control codes. ASCII was designed to be compatible with most of the existing encoding schemes at the time, such as ITA 2, FIELDATA, and EBCDIC. ASCII also added features for devices other than teleprinters, such as sorting and formatting. 

ASCII became the de facto standard for data communication in the 1980s and 1990s. It was widely adopted by personal computers, networks, operating systems, programming languages, and the Internet. ASCII also paved the way for more advanced encoding formats, such as Unicode, which can represent millions of characters from different languages and scripts.

ASCII, which stands for the American Standard Code for Information Interchange, is a character encoding standard for electronic communication. It was first developed in the early 1960s and became widely adopted as a way to ensure compatibility and consistency in representing text data across different computer systems and devices.

Here's a brief history of ASCII and the reasons behind its development:

Early Computers and Telecommunication:
In the early days of computing, different manufacturers developed their own character encodings to represent text using binary code. This lack of standardization led to compatibility issues when exchanging information between different computer systems and communication devices.

Teletypes and Teleprinters:
Teleprinters, also known as teletypes, were widely used for sending and receiving text messages over telegraph and telephone lines. However, there was a need for a common character set that could be universally understood and processed by these devices.

ASCII Development:
In 1963, Robert W. Bemer, an American computer scientist, proposed the development of a standard character set to address the compatibility issues. This effort led to the creation of ASCII, which was first published in 1963 and later revised in 1967.

Character Set and Encoding:
ASCII originally defined a 7-bit character set, which allowed for 128 different characters, including letters, numerals, punctuation marks, and control characters. Later, an extended version called the "Extended ASCII" was introduced, which used 8 bits, allowing for 256 characters.

Universal Standard:
ASCII quickly gained widespread acceptance and became a universal standard for character encoding in computers and communication devices. Its simplicity and compatibility made it an essential component of early computing systems.

International Standardization:
While ASCII was initially developed in the United States, it became a de facto international standard. However, as the need for representing characters from languages other than English arose, various extended character encodings and standards were developed, eventually leading to the creation of Unicode.

Legacy and Transition to Unicode:
ASCII remains relevant for basic text encoding, but for handling a broader range of characters and symbols from different languages and cultures, Unicode has largely replaced it. Unicode supports a much larger character set and is used in modern computing for internationalization and multilingual support.

In summary, ASCII was developed to address the compatibility issues arising from the lack of a standard character encoding in early computing. Its success lay in providing a common ground for representing text, facilitating communication and data exchange between different computer systems and communication devices.

## Telephones, Teletypes and Televisions

## The One Bitwise Hack They Don't Want You To Know (ACM Hates IT!)
Here's an observation: if we add 32 to any ascii uppercase letter, we can make it lowercase.

Try it for yourself (Python).
```python
ord("a")
# 97

chr(97 - 32)
# 'A'
```

Let's make sure it actually holds for all our letters:
```python
import string
#>>> string.ascii_uppercase
#'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
for i in string.ascii_uppercase:
    print(f"{i} = {ord(i)}. {i} + 32 = {chr(ord(i) + 32)} ({ord(i) + 32})")
```
Taking a quick peek at the output:

```
A = 65. A + 32 = a (97)
B = 66. B + 32 = b (98)
C = 67. C + 32 = c (99)
D = 68. D + 32 = d (100)
E = 69. E + 32 = e (101)
F = 70. F + 32 = f (102)
G = 71. G + 32 = g (103)
H = 72. H + 32 = h (104)
I = 73. I + 32 = i (105)
J = 74. J + 32 = j (106)
K = 75. K + 32 = k (107)
L = 76. L + 32 = l (108)
M = 77. M + 32 = m (109)
N = 78. N + 32 = n (110)
O = 79. O + 32 = o (111)
P = 80. P + 32 = p (112)
Q = 81. Q + 32 = q (113)
R = 82. R + 32 = r (114)
S = 83. S + 32 = s (115)
T = 84. T + 32 = t (116)
U = 85. U + 32 = u (117)
V = 86. V + 32 = v (118)
W = 87. W + 32 = w (119)
X = 88. X + 32 = x (120)
Y = 89. Y + 32 = y (121)
Z = 90. Z + 32 = z (122)
```

## Resources

https://www.youtube.com/watch?v=gd5uJ7Nlvvo

https://stackoverflow.com/questions/3569874/how-do-uppercase-and-lowercase-letters-differ-by-only-one-bit

https://stackoverflow.com/questions/54536362/what-is-the-idea-behind-32-that-converts-lowercase-letters-to-upper-and-vice

https://www.geeksforgeeks.org/lower-case-upper-case-interesting-fact/

https://retrocomputing.stackexchange.com/questions/14596/how-does-the-shift-key-in-a-keyboard-work

http://www.catb.org/esr/faqs/things-every-hacker-once-knew/#_ascii

https://catonmat.net/ascii-case-conversion-trick

https://www.reddit.com/r/ProgrammerTIL/comments/apb6in/til_you_can_xor_the_ascii_code_of_an_uppercase/

https://studyalgorithms.com/string/easiest-way-to-change-case-of-alphabets/

https://www.techiedelight.com/bit-hacks-part-4-playing-letters-english-alphabet/

https://www.ascii-code.com/timeline

https://ethw.org/ASCII
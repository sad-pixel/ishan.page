---
title: Scraping the MPB website - A Postmortem
tags: [python, scraping, postmortem, legacy
]
date: 2014-10-09
slug: 2014-10-09-mpb-scraper-postmortem
categories:
- Legacy
---

> **A note to the reader**
> 
> This post is a legacy post. The legacy posts that are available on this website were written many years ago. These posts are made available here **for archival purposes only**.   
> They reflect the age I was, and the level of knowledge that I had when I wrote them, and they **may contain outdated information**, so please keep that in mind as you proceed to read this article.

# Introduction
Last week, I scraped the [School Website](http://mpbfhsschool.com) clean looking for report cards. I wanted the data to do some statistics (the website is very spartan) and, much to my pleasure, I was successfully able to get all the data I need.

# The Problem
I need the report card data in **JSON** format. The format given is, quite unsurprisingly, Bad HTML

## Problem 1: Bad HTML
 The Website is built with ASP.NET. What better can I expect?
 **Tables in tables**
 
```html
  <td><table width='100%' border='0' cellspacing='0' cellpadding='0' style='border-bottom: 1px #000000 solid'><tr><td style='border-right: 1px #000000 solid'>&nbsp;</td><td style='font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; color: #000000; padding: 3px 3px 3px 5px;border-right: 1px #000000 solid'>Subject</td>
```

That's an example of the stuff I had to deal with

## Problem 2: Inconsistent ID Numbers
Come on. Who would expect people from Class 11 and 12 to have joined the school in 2014?

# The Solution
## Solution 1: Xpath
XPath is what saved me. True, it took some analysis, but I got a working thing ready
## Solution 2: Python + lxml
Python was used to write the bruteforcing script. It's what helped me to make it easier to work with the tedious job

Lxml was used to parse the Xpath and extract the data

Finally some helper scripts made the data into yearly chunks, classes, segregated and organized it into nice self-contained JSON files
## Solution 3: Koding
My internet is too slow to allow the script to be practical. A VPS from [Koding](http://koding.com) helped me to get the job done in minutes instead of weeks.

The entire extraction took 15 Mins on the VPS. There were some >2500 Records,
My connection can do 25.1 records in 15 mins

# What went Right
The extraction and processing

# What went Wrong
A lot of things

- Firstly, I could have used threading. It would have made everything much much faster
- Secondly, I should have used [Scrapy](http://scrapy.org)
- Thirdly, I should have done my homework about the subjects and classes
- Fourthly, I did a lot of useless year-crawling like 2000 and 1998

# Downloads
Ok. Here you go: **data download link is now removed**

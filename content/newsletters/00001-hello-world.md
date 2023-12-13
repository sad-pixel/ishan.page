---
title: Hello, World!
date: 2023-12-13
---

## Editor's Note

Welcome to the inaugural issue of my newsletter!

Launching this newsletter has been a long time coming. While my blog has been the primary platform for sharing my thoughts and polished work, I've held off on creating a newsletter until now. In this space, I aim to offer you a closer look behind the scenes, sharing the journey of how certain projects and transitions came to life.

For instance, the process of building the interactive jq guide was both exhilarating and challenging. 

One of the hurdles involved creating the jq evaluator, a puzzle solved by leveraging Aioli.js's wasm jq distribution and innovative approaches with alpine + web components. 

Additionally, migrating the website to Hugo and Cloudflare Pages wasn't without its complexities, particularly in creating custom includes.

I'll also be sharing a lighthearted anecdote about my accidental use of jq, where I found myself instinctively generating `<option>` elements using string interpolation with raw input from ls. Sometimes, a touch of unintended creativity leads to surprisingly usable solutions!

I hope you enjoy this inaugural dive into the less polished yet insightful facets of my work. And as always, I appreciate your ongoing support and feedback.

Warm regards,
Ishan

## Experiments and Anecdotes

"To a man with jq, everything looks like JSON"

In the world of programming, sometimes our tools become an extension of our thought process. Recently, I found myself unintentionally proving this notion true. While working on a quick prototyping task, I instinctively utilized jq to generate `<option>` elements using string interpolation with raw input from ls. 

The result? A copy-pastable snippet for rapid prototyping. Who knew that accidental encounters with jq could lead to unexpectedly handy solutions?

Check out the full post [here](/blog/2023-12-07-jq-hammer-nails/)

## Featured Blog Posts

As this is the first issue, I thought why not highlight some of the articles I'm proudest of so far?

1. ["The secret life of .well-known"](/blog/2023-07-02-well-known/)  
Unveiling the often-overlooked significance of the .well-known folder, this post delves into its role and history.

2. ["Programming 'with the grain'"](/blog/2023-07-09-programming-with-the-grain/)   
A perspective on programming that aligns with the natural flow of data, this post discusses the impact of following this 'grain.' Exploring how this approach enhances program efficiency, it sheds light on the underlying beauty of programming aligned with inherent data structures.

3. ["The Ultimate Interactive JQ Guide"](/blog/2023-11-06-jq-by-example/)   
An achievement I'm particularly proud of, this comprehensive guide boasts 25 interactive examples for learning jq. It's not just a tutorial; it's an engaging journey into the heart of this powerful tool.

## Closing Thoughts

Thank you for reading the inaugral issue, your support means the world to me! 

I'd love to hear your thoughts on this issue. 

Feel free to hit reply and share your feedback, ideas, or topics you'd like to see covered in the future. Your input will help shape the upcoming editions!

Until next time,

Ishan
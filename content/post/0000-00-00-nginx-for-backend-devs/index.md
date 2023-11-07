---
title: The Backend Developer's Missing Guide to Nginx Scripting with OpenResty and Lua
tags: [nginx, linux, web]
date: 2023-08-05
draft: true
---

Having lived in the backend development world for many years, it was quite a culture shock to me when I was thrust into the world of Nginx scripting with OpenResty and Lua. 

My understanding of Nginx before I dived into the world of scripting it was fairly limited: I believed it acted as a "gateway" to my application, handling the tedious stuff like caching, SSL termination, load-balancing, etc. I knew how to configure it by hand, using `nginx.conf`, and had a lot of experience setting it up on different servers. I knew it _could_ be scripted, and that many people did, but that was about it. 

I was frustrated by the lack of resources that could help me to effectively understand making Nginx scripts and Kong plugins. This is the first post in a planned (let's see how it turns out) series of explanatory articles that I wish had existed when I was getting started. After reading this article, you should have all the context and knowledge needed to develop any Nginx/OpenResty script you want.

## The different shades of OpenResty
OpenResty is a powerful web application server that combines the power of Nginx with Lua programming language. It allows developers to build high-performance web applications and APIs. OpenResty can be used in two primary ways: as an application server or as middleware.

* **Applications**:    
    OpenResty can be used as a standalone web application server. In this case, you write your entire web application using the Lua programming language. Lua is a lightweight and efficient scripting language that can be embedded into Nginx through OpenResty. With OpenResty, you can leverage the full capabilities of Nginx and Lua to build robust and high-performance web applications. You have complete control over the request/response cycle, routing, authentication, caching, and other aspects of your application.
* **Middleware**:   
    OpenResty can also be used as middleware, sitting between the client and the backend application server. In this scenario, you can use OpenResty to enhance and extend the functionalities of an existing application or API. OpenResty acts as a proxy server, intercepting and processing requests before forwarding them to the backend. You can leverage the power of Lua scripting to perform various tasks such as authentication, rate limiting, request/response transformation, logging, and more. OpenResty middleware is particularly useful when you want to add advanced functionalities to an existing application without modifying its codebase.

## Development environment setup
https://blog.cloud66.com/supercharging-nginx-with-lua

## A hello world example

## A calculator example

## Resources
https://github.com/ketzacoatl/explore-openresty/blob/master/dev-notes.md
https://blog.cloudflare.com/pushing-nginx-to-its-limit-with-lua/
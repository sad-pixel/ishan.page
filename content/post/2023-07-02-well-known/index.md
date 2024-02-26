---
slug: 2023-07-02-well-known
title: The secret life of .well-known
date: 2023-07-02
tags: [web, standards, fediverse, featured]
description: "Find out how the humble .well-known directory is actually chock-full of bonuses that will make your web development life easier."
categories:
- featured-articles
---

My first encounter with the `.well-known` directory was when Let's Encrypt first hit the scene and I was learning about VPS-es and how Linux on the server worked. 

I noticed that it used certain URLs like `.well-known/acme-challenge/3d2f4b8c9d0a4f8b9e6f7d8c9e0a4f8b`. This led me down a nice rabbit hole about the ACME protocol, but that's a story for another time.

Years later, when configuring servers to use paid HTTPs certificates, I noticed the use of the `.well-known/pki-validation/` directory for verifying certificates. I filed this knowledge away in my brain as "the `.well-known` directory is for SSL related stuff" and continued on with my life.

Somewhere in the middle, I noticed that a lot of brute force attacks on servers I monitored would be directed to `.well-known` URLs. At that point, I had learned about DNS based verification, and quickly moved on from HTTP challenges, and blocked access to the directory in my web server configs. I made this a part of my base setup on every server, and didn't really think too much about the directory any more.

That was, until _very_ recently.

## The Fiasco with NodeInfo
As a recent migrant to the Fediverse after the Reddit API changes shut down my 3rd party app of choice, I joined a fairly interesting Lemmy instance, and I quickly found the distributed nature fascinating. All I could think about was: "I want to see a giant map of all the instances and who is connected to who", and immediately set out to create a web scraper that could gather this information for me.

> Don't worry, I made sure to respect `robots.txt` for every site the scraper visited.

Lemmy's API documentation is fairly poor, and I flailed for quite a while before I discovered the endpoint (`/api/v3/site`) that would give me the list of federated servers.

That's when I realized, that Lemmy could _and did_ federate with other Fediverse software like Mastodon, Calckey, Pleroma, WriteFreely, PixelFed and more. And each one of these have different APIs and different endpoints that would give me the data I need. 

I needed a way to detect which software each server was running. My first instinct was to use some sort of heuristic, but that's unreliable, so I continued researching and discovered the [NodeInfo](https://github.com/jhass/nodeinfo/blob/main/PROTOCOL.md) protocol.

And wouldn't you have it, the resource I need to request _just happens to be_
```
/.well-known/nodeinfo
```

At this point, my curiousity was piqued. There was more to this `.well-known` directory than I had initially thought!

## The RFC enters the fray
It [turns out](https://serverfault.com/questions/795467/what-is-the-purpose-of-the-well-known-folder), that the .well-known directory is defined in [RFC 8615](https://www.rfc-editor.org/rfc/rfc8615). The intention seems to be to make it like a generic and extendable version of `robots.txt` 

>    It is increasingly common for Web-based protocols to require the discovery of policy or other information about a host ("site-wide metadata") before making a request. For example, the Robots Exclusion Protocol http://www.robotstxt.org/ specifies a way for automated processes to obtain permission to access resources; likewise, the Platform for Privacy Preferences [W3C.REC-P3P-20020416] tells user-agents how to discover privacy policy beforehand.
>
>
>    While there are several ways to access per-resource metadata (e.g., HTTP headers, WebDAV's PROPFIND [RFC4918]), the perceived overhead (either in terms of client-perceived latency and/or deployment difficulties) associated with them often precludes their use in these scenarios.
>
>
>    When this happens, it is common to designate a "well-known location" for such data, so that it can be easily located. However, this approach has the drawback of risking collisions, both with other such designated "well-known locations" and with pre-existing resources.
>
>
>    To address this, this memo defines a path prefix in HTTP(S) URIs for these "well-known locations", /.well-known/. Future specifications that need to define a resource for such site-wide metadata can register their use to avoid collisions and minimise impingement upon sites' URI space.

There's a whole [**bunch** of stuff](https://en.wikipedia.org/w/index.php?title=Well-known_URI#List_of_well-known_URIs) that you can do with stuff in the `.well-known` folder, like:
* [Automate email client configuration for self hosted email](https://www.hardill.me.uk/wordpress/2021/01/24/email-autoconfiguration/)
* [Let password managers automatically know which URL to visit to change a password](https://web.dev/change-password-url/)
* [Let ChatGPT discover your plugin](https://platform.openai.com/docs/plugins/getting-started)
* [Discover Matrix server details](https://spec.matrix.org/latest/client-server-api/#well-known-uri)

and of course, let's not forget about [Webfinger](https://webfinger.net/).

> “A webfinger? Is that what I use to poke someone on Facebook?” - Anonymous

**UPDATE 2023-07-04**: I have published a follow-up - [Addendum: Webfinger](/blog/2023-07-04-addendum-webfinger)

**UPDATE 2023-07-07**: This article was featured in [tldr.tech](https://tldr.tech/tech/2023-07-07), and as of time of writing I have had over 6500 hits on this post. I am overwhelmed and moved by this, and by all the positive comments I have received. I never imagined that my little blog would ever be read by so many people.

---
title: Using different Github accounts with different private keys on Linux
tags: [linux, git, github, ssh]
date: 2023-06-21
categories:
- Snippets
slug: 2023-06-21-linux-use-multiple-git-profiles
---

Create a file `~/.ssh/config`

If you have 2 keys, for example: `id_rsa` for your personal, and `id_work` for your work, set the config as:

```
Host github-work
    HostName github.com
    IdentityFile ~/.ssh/id_work
    IdentitiesOnly yes
```

Now, when cloning or adding remote, change the `github.com` in the clone url is changed to `github-work`

```
git clone git@github-work:username/whatever.git
```

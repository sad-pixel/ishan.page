---
title: Fix WSL time drift
tags: [windows, wsl]
date: 2023-03-08
slug: 2023-03-08-wsl-time-drift
categories:
- Snippets
---

There is a bug in WSL2 that causes the clock inside the VM to drift behind the actual clock on the machine. 

This can lead to many unexpected issues, ranging from harmless (git commit messages having old timestamps) to
severe (SSL connection failures). 

We can sync the VM clock using the command
```sh
sudo hwclock -s
```

We can also add the command as a cron job every 5-10 minutes to make sure that the clock doesn't drift too far back.

{{% read-next %}}

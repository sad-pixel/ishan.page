---
title: Discord Notifications from Systemd
tags: [discord, linux, systemd]
date: 2021-10-15
categories:
- Snippets
slug: 2021-10-15-systemd-discord-notify
---

Add the following lines in your service definition file (`/etc/systemd/system/service_xyz.service`) in the `[Service]` section:

```
ExecStartPost=/home/service_xyz/hooks.sh start
ExecStopPost=/home/service_xyz/hooks.sh stop
```

In `/home/service_xyz/hooks.sh`, put
```sh
#!/bin/bash

hook_url=https://discord.com/api/webhooks/xxxxxxxxxxxx/yyyyyyyyyy

case "$1" in
 start)
  curl -H "Content-type: application/json" \
  -X POST -d \
  '{
    "content":"Hook: <NAME>; Action Start"
  }' $hook_url
   ;;
 stop)
  curl -H "Content-type: application/json" \
  -X POST -d \
  '{
    "content":"Hook: <NAME>; Action Stop"
  }' $hook_url
   ;;
esac

exit 0   
```

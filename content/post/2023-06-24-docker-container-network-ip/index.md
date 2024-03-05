---
title: Get Docker Containers running in a particular network
tags: [docker, networking]
slug: 2023-06-24-docker-container-network-ip
date: 2023-06-24
categories:
- Snippets
---

The following script can be used to start list the running containers inside a particular network along with their ips.

```sh
#! /usr/bin/zsh
echo "Image\tHostname\tIP";
for N in $(docker ps -q) ; do echo "$(docker inspect -f '{{.Config.Image}}\t{{ .Config.Hostname }}\t' ${N}) $(docker inspect -f '{{range $i, $value := .NetworkSettings.Networks}}{{if eq $i "custom_network_name"}}{{.IPAddress}}{{end}}{{end}}' ${N})"; done
```

Usage example:
```
./network-hosts
```

Bonus tip:   
Pipe the output into `column -t` like so to get a pretty formatted tabular output.
```
./network-hosts | column -t
```

{{% read-next %}}

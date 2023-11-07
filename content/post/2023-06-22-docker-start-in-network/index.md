---
title: Start a container in a particular docker network
tags: [docker, networking]
date: 2023-06-22
categories:
- Snippets
---

The following script can be used to start a container inside a particular network.

Usage example:
```
./start-in-network redis
./start-in-network vad1mo/hello-world-rest 5050
```


```sh
#!/usr/bin/zsh

if [ $# -eq 0 ]
then
    echo "syntax: ./start-in-network container-name [container port binding]"
    echo "You must provide at least container name"
    exit 1
fi

docker_container_id=""
if [ $# -eq 1 ]
then
    docker_container_id=$(docker run -d $1)
else
    docker_container_id=$(docker run -d -p $2:$2 $1)
fi

docker network connect custom_network_name docker_container_id
```
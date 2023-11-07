---
title: Generate PEM file for any Linux user
tags: [linux, ssh]
date: 2021-09-18
categories:
- Snippets
---
Quickly and easily generate a key pair for passwordless connection. Also works perfect as git deploy keys!

## Generate the keys

**DO NOT DO THIS AS ROOT**

Run the command to generate the keys

```sh
$ ssh-keygen -P "" -t rsa -b 4096 -m pem -f my-key-pair
```

* `-b` flag sets the bits, 4096 is recommended
* `-m pem` is needed to generate a file in RSA Private Key format, not in OpenSSH Private Key format
* `-f` specifies the output key pair
* replace `my-key-pair` with the name of your key pair (preferably `deploy_key` or `access_key`)

This will generate two files:

* `my-key-pair` - this is your PEM file, copy paste the contents
* `my-key-pair.pub` - this is the corresponding public key file

Note: You may want to rename the `my-key-pair` to `my-key-pair.pem` for convenience.

## Set the key to allow login

In order to be able to log in using the generated PEM file, you should add the public key to the authorized_keys list. To do that, run

```
# Ignore this step if you have other public keys added
$ touch ~/.ssh/authorized_keys

$ cat my-key-pair.pem >> ~/.ssh/authorized_keys
```
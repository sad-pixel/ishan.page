---
title: Accidentally deleted your .bashrc?
tags:
- bash
- linux
- shell
- skel
date: 2023-11-28
slug: 2023-11-28-bashrc-oopsie-deleted
---

When beginning to use the terminal, we might accidentally delete our `.bashrc` file.

## What is the .bashrc file?

The `.bashrc` file is a configuration file used by the bash shell. It contains all the environment variables, user defined functions, aliases and other config including the prompt layout.

It is a full-fledged shell script, so we can have custom commands in it as well, which runs all the commands when a new process of the shell is started.

## What happens if I delete it by accident?

It's totally possible to delete your .bashrc file by accident. If you do this, don't panic. Your system isn't bricked. 

Bash will default back to the `/etc/bash.bashrc` file. 

This may affect some features (such as colors, prompt, completion, etc), but the shell will still work.

To see what it is like, we can call a custom session of bash with the command:
```sh
bash --rcfile /etc/bash.bashrc
```

Deleting the `/etc/bash.bashrc` file will make bash use the default settings from the source code. To get a simulation of that, we can run

```sh
bash --norc
```

## Restoring Your Config

There's a special folder in *nixes called `/etc/skel`. 

It contains all the files needed for creating a new user, and thankfully, it contains a sample "skeleton" `.bashrc` file that we can copy into our home directory.

```sh
cp /etc/skel/.bashrc ~/.bashrc
```

While there isn't any way to get back our custom commands, we can still get a lot of stuff out **as long as you still have a logged in session**

The `declare` built-in command in Bash is used to declare variables and give them attributes. When used with the -x option, it declares the variable as an exported variable, making it available to child processes. Exported variables are passed to any commands or scripts invoked from the current shell. However, if we run `declare -x` by itself without giving any other parameters, it conveniently prints a list of the exported environment variables for us. The `-f` flag works in a similiar way, but with functions

```shell
# Recover Environment
echo "$(declare -x)" >> ~/.bashrc

# Recover Functions
echo "$(declare -f)" >> ~/.bashrc

# Recover aliases
echo "$(alias)" >> ~/.bashrc
```

The `env` command also gives us the same output, so it can be used for this purpose as well.

## Making and Restoring Backups

It may be worth taking a backup of your bashrc
```sh
cp ~/.bashrc ~/.bashrc.bkp
# Restore
cp ~/.bashrc.bkp ~/.bashrc
```

## A note on Dotfile Management with Stow

Stow is a symlink manager that creates symbolic links from a source directory to a target directory, avoiding conflicts and duplicates
To use git and stow for dotfile management, one possible workflow is outlined [here.](https://apiumhub.com/tech-blog-barcelona/managing-dotfiles-with-stow/)

## Closing Thoughts

It's okay to make mistakes. A fear of messing things up prevents us from playing around to learn. The beauty of learning is in making mistakes. I've deleted my `.bashrc` file before-- it's nothing to be ashamed of!

Have you deleted your `.bashrc` or other important dotfiles before? Do you already have a workflow with Stow? [I'd love to hear about it](mailto:hello@ishan.page)!.
{{% read-next %}}

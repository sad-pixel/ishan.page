---
title: Send Applescript Notifications from your CLI easily with this nifty alias
tags:
- shell
- bash
- macos
date: 2024-12-12
slug: macos-notify-cli
categories:
- Snippets
---

Have you ever wanted to send desktop notifications from your command line on macOS? 

This can be particularly useful when you want to be notified when a long-running process completes. For example, you could append `; notify "Task completed!"` to any command.

While there are several ways to do this, I find using AppleScript through the `osascript` command to be the simplest approach. Here's a handy shell function that lets you send notifications with just a single command.

To use this notification function, you'll need to add it to your shell's configuration file. If you're using zsh (the default shell on modern macOS), add the following function to your `~/.zshrc` file. If you're using bash, add it to your `~/.bashrc` instead.

```bash
notify() {
  local message="$1"
  local title="${2:-Notification}" 

  if [[ -z "$message" ]]; then
    echo "Usage: notify <message> [title]"
    return 1
  fi

  osascript -e "display notification \"$message\" with title \"$title\""
}
```

## Usage
With a custom title:
```bash
notify "hello world!" "Custom Title"
```
Without a custom title:
```bash
notify "hello world!"
```
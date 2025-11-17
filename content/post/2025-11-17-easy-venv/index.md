---
title: Easy alias for dealing with Python Virtualenvs
tags:
  - shell
  - bash
  - python
date: 2025-11-17
slug: easy-venv-script
categories:
  - Snippets
---

There’s something oddly comforting about a shell function that takes care of boring things for you.

This `venv()` helper does exactly that.

It checks whether you’re already in an environment, spins up a fresh one if needed, installs your dependencies, and activates it.

To use this `venv` function, you’ll need to add it to your shell’s configuration file. If you’re using zsh, add the following function to your ~/.zshrc file. If you’re using bash, add it to your ~/.bashrc instead.

Don't forget to `source ~/.zshrc` or `source ~/.bashrc` later!

This requires `uv` to work

```bash
venv() {
  # Exit early if already in a virtual environment
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "A virtual environment is already active at: $VIRTUAL_ENV"
    return 1
  fi

  # Create .venv if missing
  if [[ ! -d ".venv" ]]; then
    echo "Creating virtual environment..."
    uv venv || { echo "Failed to create venv"; return 1 }

    # Install dependencies if requirements.txt exists
    if [[ -f "requirements.txt" ]]; then
      echo "Installing dependencies..."
      uv pip install -r requirements.txt || { echo "Dependency install failed"; return 1 }
    else
      echo "No requirements.txt found; skipping installation."
    fi
  fi

  # Activate the environment
  source .venv/bin/activate
}
```

Of course, if you use `uv run` for running things anyway, then you don't need this!

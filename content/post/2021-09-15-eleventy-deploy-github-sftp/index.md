---
title: Build and Deploy Eleventy via SFTP using Github Actions
tags: [github, deployment, ssh, eleventy]
date: 2021-09-15
categories:
- Snippets
---

1. Navigate to Repository > Settings > Secrets > New Repository Secret
2. Set the name as SSH_PRIVATE_KEY
3. Paste the contents of the key file

```yaml
# .github/workflows/build.yaml

name: Build and Deploy PROJECT_NAME

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [14.x]
    
    steps:
      - uses: actions/checkout@v2

      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v1
        with:
          node-version: ${{ matrix.node-version }}
      
      - name: Install dependencies & build
        run: |
          npm ci
          npm run build:assets
          npm run build:site
      
      - name: Deploy build
        uses: wlixcc/SFTP-Deploy-Action@v1.2.1
        with:
          username: 'domain.user'
          server: 'server.host'
          ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
          local_path: './dist/*'
          remote_path: 'site_home_dir'
          args: '-o ConnectTimeout=5'
```
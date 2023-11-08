---
title: Parsing single level yaml files into a Lua table
tags: [lua, yaml]
date: 2023-06-23
slug: 2023-06-23-lua-yaml-dict
categories:
- Snippets
---

Given a yaml-like file containing key-value pairs like this:
```yaml
key1: value1
key2: value2
key3: value3
```
The following function will load it and return the data as a Lua table.

```lua
function read_yaml_file(filename)
  local file = io.open(filename, "r")
  if not file then
    return nil, "Failed to open file: " .. filename
  end

  local data = {}
  for line in file:lines() do
    local key, value = line:match("(%w+):%s*(.+)")
    if key and value then
      data[key] = value
    end
  end

  file:close()
  return data
end
```

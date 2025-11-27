---
title: How to Handle "Bracket" Array Query Parameters (key[]=val) in FastAPI
slug: "fastapi-query-arrays"
date: 2025-11-27
tags: ["python", "fastapi", "middleware", "web"]
---

FastAPI expects array parameters in the standard `key=v1&key=v2` format. However, many frontend client generators like my favourite, **Orval**, default to `key[]=v1&key[]=v2`.

If you cannot change the client configuration, FastAPI will fail to validate these lists.

The fix is to add a middleware that strips the brackets from keys before the request reaches the routing layer.

## The Code

This middleware intercepts the HTTP scope, reconstructs the `query_string`, and ensures it is re-encoded to `bytes` to avoid `AttributeError: 'str' object has no attribute 'decode'` errors in Uvicorn.

```python
from fastapi import Request, FastAPI
from fastapi.datastructures import QueryParams

class FixListQueryParamsMiddleware:
    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        # Adapted from https://github.com/fastapi/fastapi/discussions/7827#discussioncomment-5144572
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        request = Request(scope)
        
        # Rebuild params: strip "[]" from keys ending with it
        new_items = [
            (key[:-2] if key and key.endswith("[]") else key, value)
            for key, value in request.query_params.multi_items()
        ]
        
        scope["query_string"] = bytes(str(QueryParams(new_items)), "ascii")
        
        await self.app(scope, receive, send)
```

## Usage

Register the class directly in your FastAPI app initialization:

```python
app = FastAPI()
app.add_middleware(FixListQueryParamsMiddleware)

@app.get("/users")
def get_users(ids: list[int] = None):
    # Request: GET /users?ids[]=1&ids[]=2
    # Result: ids=[1, 2]
    return ids
```

*Context: See [FastAPI Discussion #7827](https://github.com/fastapi/fastapi/discussions/7827).*

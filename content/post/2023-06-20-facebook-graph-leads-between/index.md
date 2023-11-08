---
title: Get leads collected by a particular lead ad form between two timestamps using Facebook Graph API
tags: [facebook, python]
date: 2023-06-20
categories:
- Snippets
slug: 2023-06-20-facebook-graph-leads-between
---

Given two unix timestamps, this Python script fetches all the leads received by a particular Facebook Lead Ads form using the Facebook v14 Graph API.

```python
import json
import requests

# Constants
ACCESS_TOKEN="YOUR_ACCESS_TOKEN"
LIMIT=500
FROM_TIMESTAMP=1678613400
UPTO_TIMESTAMP=1678704000
FORM_ID=12341241244

def create_api_url(form_id):
    return f"https://graph.facebook.com/v14.0/{form_id}/leads"

def filter_tpl(gt, lt):
    f = [
        {
            "field": "time_created",
            "operator": "GREATER_THAN",
            "value": gt
        },
        {
            "field": "time_created",
            "operator": "LESS_THAN",
            "value": lt
        }
    ]
    return json.dumps(f)

def do_query(form_id, gt, lt):
    url = create_api_url(form_id)

    querystring = {"access_token":ACCESS_TOKEN,"limit":str(LIMIT),
        "filtering":filter_tpl(gt, lt)}

    payload = ""
    response = requests.request("GET", url, data=payload, params=querystring)

    print(response.text)

if __name__ == '__main__':
    do_query(FORM_ID, FROM_TIMESTAMP, UPTO_TIMESTAMP)
```


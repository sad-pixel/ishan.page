---
slug: 2023-07-04-addendum-webfinger
title: "Addendum: What's a Webfinger?"
date: 2023-07-04
tags: [web, fediverse, standards]
---

Following an interesting discussion on [programming.dev](https://programming.dev/post/375331) after the [last article](/blog/2023-07-02-well-known), I thought it would be good to add some extra notes regarding Webfinger.

Webfinger provides a standard API for discovering the user profile details and avatar from the username, no matter the software running on the node. The standard Webfinger endpoint is `/.well-known/webfinger`. It must always be queried with at least the resource.

Some examples using my account  on Lemmy (programming.dev) and Mastodon (hachyderm.io):

```sh
$ curl https://programming.dev/.well-known/webfinger\?resource\=acct:ishanpage@programming.dev | jq
```

```json
{
  "subject": "acct:ishanpage@programming.dev",
  "links": [
    {
      "rel": "http://webfinger.net/rel/profile-page",
      "type": "text/html",
      "href": "https://programming.dev/u/ishanpage"
    },
    {
      "rel": "self",
      "type": "application/activity+json",
      "href": "https://programming.dev/u/ishanpage",
      "properties": {
        "https://www.w3.org/ns/activitystreams#type": "Person"
      }
    }
  ]
}
```

```sh
curl https://hachyderm.io/.well-known/webfinger\?resource\=acct:ishands@hachyderm.io | jq
```

```json
{
  "subject": "acct:ishands@hachyderm.io",
  "aliases": [
    "https://hachyderm.io/@ishands",
    "https://hachyderm.io/users/ishands"
  ],
  "links": [
    {
      "rel": "http://webfinger.net/rel/profile-page",
      "type": "text/html",
      "href": "https://hachyderm.io/@ishands"
    },
    {
      "rel": "self",
      "type": "application/activity+json",
      "href": "https://hachyderm.io/users/ishands"
    },
    {
      "rel": "http://ostatus.org/schema/1.0/subscribe",
      "template": "https://hachyderm.io/authorize_interaction?uri={uri}"
    }
  ]
}
```

While I'm not sure _exactly_ how this is useful, my assumption is that it's useful during federation, and for generic activitypub clients because different Fediverse software maps usernames and profiles differently.

{{% read-next %}}

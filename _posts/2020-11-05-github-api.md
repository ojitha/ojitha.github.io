---
layout: post
title: "GitHub API"
date:   2020-11-05
categories: [GitHub]
---

GitHub API is hypermedia based. This is very basic post introducing how to interact with GitHub API using `curl` and the `jq` tools.

<!--more-->

The GitHub API is based on hypermedia API. The very first request most basic GitHub API:

```bash
curl -s https://api.github.com
```

This is API references within the API, which is a nice part of Hypermedia based APIs.

> A Hypermedia Type is a media type that contains native hyperlinking elements that can be used to control application flow. Hypermidea types are SVG, HTML, Atom and so on.

To extract current user URL:

```bash
curl https://api.github.com | jq '.current_user_url'
```

This will give you the output of `"https://api.github.com/user"`.

To list my information

```bash
curl -s https://api.github.com/users/ojitha
```

Get my avatar url:

```bash
curl -s https://api.github.com/users/ojitha | jq '.avatar_url'
```

I can list all of my projects as follows

```bash
curl -s https://api.github.com/users/ojitha/repos  | jq .[].name
```

To get the information about https://ojitha.github.io:

```bash
curl -s https://api.github.com/users/ojitha/repos  | jq '.[] | select(.name == "ojitha.github.io")'
```

For some API request you have to provide **personal token** for authentication:

```bash
curl -u ojitha:<token> https://api.github.com/rate_limit
```


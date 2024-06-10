---
title: "Blogging with Jupyter Notebooks in Hugo"
date: 2023-12-15
slug: 2023-12-15-hugo-ipython-jupyter
tags: ["python", "hugo", "programming", "web", "jq", "jupyter"]
image: "hugo_jupyter.png"
description: "Fun Fact: The Notebooks are JSON Files"
---
> Featured Photo by [Simon Berger](https://www.pexels.com/photo/silhouette-of-mountains-1323550/)

I've realized something important about myself lately: I need to make it easy for me to publish my stuff.  If I have to do a lot of steps to get my text online, I lose motivation and give up. That's why I switched from my custom PHP site to a hugo site with a ready-made theme on Cloudflare pages. Now I just have to `git push` and it's done.

I used to hate working with Jupyter notebooks because they required me to open a browser and deal with all the hassle of web interfaces. But ever since VS Code added support for `.ipynb` files, I've changed my mind. 

Now I can easily play around with code and data, and see the results in real time. It's great for learning new things.

One cool feature of Jupyter notebooks is that they can have markdown cells, where you can write text with formatting. That got me thinking: what if I could use Jupyter notebooks to write blog posts and then render them in hugo? That would be awesome, right?

I present to you:
```
{{ % ipynb "simple.ipynb" % }}
```

The rest of this post is written in the Jupyter notebook.
{{% ipynb "simple.ipynb" %}}

{{% newsletter %}}

***
{{% read-next %}}

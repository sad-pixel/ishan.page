---
title: Easy Jigsaw Puzzle Embed for Your Website
tags:
  - web
  - programming
  - javascript
date: 2025-04-22
slug: jigsaw-puzzle-embed
---

I wanted to share a small project I've been working on - a simple jigsaw puzzle embed that you can add to any website.

## What It Does

It's a straightforward tool that lets you embed customizable jigsaw puzzles into your web pages. You can:

- Use any image as the puzzle
- Choose the background color
- Set the difficulty by adjusting the number of pieces

When someone completes the puzzle, it sends a "puzzleSolved" message that your site can detect.

## How to Add It

Just include this iframe in your HTML:

```html
<iframe
  src="https://jigsaw.ishan.page?img=https://example.com/your-image.jpg&bg=ffffff&pieces=25"
  width="600"
  height="400"
  frameborder="0"
>
</iframe>
```

## Detecting When the Puzzle is Solved

Here's a simple code example to detect when someone completes your puzzle:

```javascript
window.addEventListener("message", function (event) {
  // The puzzle uses parent.postMessage("puzzleSolved","*") when completed
  if (event.data === "puzzleSolved") {
    console.log("Puzzle completed!");
    // Do something when the puzzle is solved
  }
});
```

## Credits

This is essentially Dillo's jigsaw puzzle (https://codepen.io/Dillo/pen/QWKLYab) with very minor adaptations to make it work as an embed. I just added the iframe functionality and message event.

The puzzle is hosted at https://jigsaw.ishan.page if you want to check it out.

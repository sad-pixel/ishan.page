---
title: Easy Jigsaw Puzzle Embed for Your Website
tags:
  - web
  - programming
  - javascript
date: 2025-04-22
slug: jigsaw-puzzle-embed
---

<script src="https://unpkg.com/alpinejs" defer></script>

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

## Try It Out

Here's a live configurator where you can customize your own puzzle embed:

<script>
document.addEventListener('alpine:init', () => {
  Alpine.data('puzzleConfigurator', () => ({
    imageUrl: 'https://images.unsplash.com/photo-1682687220063-4742bd7fd538?q=80&w=1000',
    bgColor: 'ffffff',
    pieces: 16,
    width: 600,
    height: 400,
    getIframeCode() {
      return `<iframe
  src=\"https://jigsaw.ishan.page?img=${this.imageUrl}&bg=${this.bgColor}&pieces=${this.pieces}\"
  width=\"${this.width}\"
  height=\"${this.height}\"
  frameborder=\"0\"></iframe>`;
    }
  }))
})
</script>

<style>
input, textarea {
  font-family: monospace !important;
  display: block;
  background-color: var(--pre-background-color);
  color: var(--pre-text-color);
  width: 100%;
}

button {
  background: var(--accent-color);
  box-shadow: var(--shadow-l2);
  border-radius: var(--tag-border-radius);
  padding: 8px 20px;
  color: var(--accent-color-text);
  font-size: 1.4rem;
  transition: all .3s ease;
  border: 0;
  cursor: pointer;
}

button:hover {
  background: var(--accent-color-darker);
}

.reset-button {
  padding: 4px 8px;
  font-size: 0.9rem;
}

.flex-row {
  display: flex;
  flex-direction: row;
  gap: 15px;
  margin-bottom: 20px;
}

.flex-col {
  display: flex;
  flex-direction: column;
}

.col-50 {
  flex: 1 1 50%;
}

.col-25 {
  flex: 1 1 25%;
}

.col-75 {
  flex: 1 1 75%;
}

.color-preview {
  display: inline-block;
  width: 20px;
  height: 20px;
  vertical-align: middle;
  margin-left: 5px;
}

details {
  margin-bottom: 20px;
}

summary {
  cursor: pointer;
  font-weight: bold;
  margin-bottom: 10px;
}

input[type="range"] {
  width: 100%;
}

input[type="number"], input[type="text"] {
  width: 100%;
}
</style>

<div x-data="puzzleConfigurator">
<div class="flex-col" style="margin-bottom: 20px;">
<label for="imageUrl">Image URL:</label>
<input type="text" id="imageUrl" x-model="imageUrl">
</div>

<div class="flex-row">
<div class="flex-col col-25">
<label for="bgColor">Background Color:</label>
<div style="display: flex; align-items: center;">
<input type="text" id="bgColor" x-model="bgColor">
<span class="color-preview" x-bind:style="'background-color: #' + bgColor + ';'"></span>
</div>
</div>

<div class="flex-col col-75">
<label for="pieces">Number of Pieces: <span x-text="pieces"></span></label>
<input type="range" id="pieces" x-model.number="pieces" min="4" max="100" step="1">
</div>
</div>

<div class="flex-row">
<div class="flex-col col-50">
<label for="width">Width (px):</label>
<div style="display: flex; align-items: center; gap: 10px;">
<input type="number" id="width" x-model.number="width" min="200" max="1200">
<button @click="width = 600" class="reset-button">Reset</button>
</div>
</div>

<div class="flex-col col-50">
<label for="height">Height (px):</label>
<div style="display: flex; align-items: center; gap: 10px;">
<input type="number" id="height" x-model.number="height" min="200" max="1200">
<button @click="height = 400" class="reset-button">Reset</button>
</div>
</div>
</div>

<div style="margin-bottom: 20px;">
<span x-text="'Current aspect ratio: ' + (width/height).toFixed(2)" style="font-style: italic;"></span>
<button @click="width = 600; height = 400" style="margin-left: 10px;" class="reset-button">Reset Dimensions</button>
</div>

<details>
<summary>Your Embed Code</summary>
<textarea x-text="getIframeCode()" style="height: 100px;" readonly></textarea>
</details>
<button @click="navigator.clipboard.writeText(getIframeCode())" style="margin-top: 10px;">Copy to Clipboard</button>

<div style="margin-bottom: 20px;">
<h4>Preview:</h4>
<div x-html="getIframeCode()" style="width: 100%;"></div>
</div>
</div>

## Credits

This is essentially Dillo's jigsaw puzzle (https://codepen.io/Dillo/pen/QWKLYab) with very minor adaptations to make it work as an embed. I just added the iframe functionality and message event.

The puzzle is hosted at https://jigsaw.ishan.page if you want to check it out.

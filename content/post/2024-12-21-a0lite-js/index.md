---
title: Announcing a new chess bot - A0lite-js
description: A0lite-js is a web-native chess engine that is compatible with Leela Chess Zero Networks
tags:
  - chess
  - programming
  - javascript
  - webassembly
date: 2024-12-21
slug: a0lite-js
---

I'm excited to share a project I've been working on - a TypeScript port of the a0lite chess engine. The original a0lite was created as a minimalist neural network chess engine, designed to be simple and easy to understand rather than maximize playing strength.

You can play against the engine by sending it a challenge [here](https://lichess.org/?user=A0Lite-JS#friend). Please note that the bot can only play 3 simultaneous challenges at a time. It accepts bullet, blitz, and rapid challenges, casual or rated.

[![lichess-rapid](https://lichess-shield.vercel.app/api?username=A0lite-js&format=bullet)](https://lichess.org/@/A0lite-js/perf/bullet)
[![lichess-rapid](https://lichess-shield.vercel.app/api?username=A0lite-js&format=blitz)](https://lichess.org/@/A0lite-js/perf/blitz)
[![lichess-rapid](https://lichess-shield.vercel.app/api?username=A0lite-js&format=rapid)](https://lichess.org/@/A0lite-js/perf/rapid)

## What was a0lite?

The original [dkappe/a0lite](https://github.com/dkappe/a0lite) project was a Python implementation of a basic neural MCTS chess engine in just 95 lines of code. Unlike Leela Chess Zero (LC0) which is a full Alpha Zero clone with thousands of lines of C++ code, a0lite took a much simpler approach:

- Single-threaded MCTS/UCT search
- No complex pruning or tree reuse optimizations
- Minimal, readable implementation focused on the core concepts
- Designed for experimentation and learning

While the original project has been inactive since November 2020, it provided an excellent foundation for understanding neural network chess engines without the complexity of production systems.

## Why TypeScript?

While there is an Emscripten port of LC0 that can run in browsers, it has significant limitations and performance issues. By reimplementing the core concepts in TypeScript, we can create an engine that:

- Runs natively in modern browsers without emulation overhead
- Takes advantage of WebAssembly and Web Workers for better performance
- Has a smaller footprint and faster load times
- Integrates smoothly with web technologies and frameworks

## What is a0lite-js?

a0lite-js is a TypeScript implementation that builds on the original a0lite's philosophy of simplicity while adding features needed for practical use. It's designed to work with LC0 neural networks that have been converted to the ONNX format, making them usable in JavaScript/TypeScript environments.

The engine implements:

- UCI (Universal Chess Interface) protocol for compatibility with chess GUIs
- Monte Carlo Tree Search (MCTS) with UCT for position evaluation
- Neural network inference using ONNX Runtime
- Support for both standard chess positions and custom FEN positions

## Current Limitations

While the engine plays reasonably well in many positions, it has some significant weaknesses:

1. **Mate Blindness**: The engine sometimes misses obvious checkmates, even when they're just a few moves away. This is partly due to the MCTS implementation not specifically prioritizing mate-seeking lines.
2. **Draw Tendencies**: A major issue is the engine's propensity to fall into threefold repetition in winning positions. Even with a clear advantage, it may choose moves that allow the opponent to force a draw through repetition. This behavior stems from:
   - Insufficient exploration of alternative winning lines
   - Lack of proper draw-avoidance heuristics in the search
   - The neural network's training data possibly including too many drawn games
3. **Time Management**: The current time management system is basic and can lead to suboptimal move choices under time pressure.

## Future Development

I'm actively working on addressing these limitations. Key areas of focus include:

- Implementing mate detection in the search
- Adding draw-avoidance heuristics
- Improving time management
- Optimizing the MCTS implementation for browser environments
- Supporting more UCI options
- Exploring WebAssembly for performance-critical components
- Adding Web Worker support for background processing

The goal is to create a strong, web-native chess engine that maintains strategic understanding while addressing tactical weaknesses.

## Getting Started

You can play against the engine by sending it a challenge [here](https://lichess.org/?user=A0Lite-JS#friend).

To try out a0lite-js on your own computer, you will need to have git, bun and lc0 already installed. After that, do the following steps:

1. Clone the repository and install dependencies:

   ```bash
   git clone https://github.com/sad-pixel/a0lite-js.git
   cd a0lite-js
   bun install
   ```

2. Convert your LC0 network to ONNX format using:

   ```bash
   lc0 leela2onnx --input=<path-to-network-file> --output=lc0.onnx
   ```

   Place the resulting ONNX model in the `nets` directory.

3. Run the engine using Bun:

   ```bash
   bun run index.ts
   ```

This will start a0lite-js as a UCI chess engine that can be used with any UCI-compatible chess GUI. The engine can also be integrated directly into web applications.

You can play against the engine by sending it a challenge [here](https://lichess.org/?user=A0Lite-JS#friend). Please note that the bot can only handle 3 challenges at the same time.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests on GitHub. In particular, help with addressing the mate detection and draw-avoidance issues would be greatly appreciated.

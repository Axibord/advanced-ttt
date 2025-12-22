# Advanced Tic-Tac-Toe

A Tic-Tac-Toe implementation in Gleam, supporting dynamic board sizes and LShape game mode.

## Architecture

The project follows a functional core with an imperative shell:

- `tic_tac_toe.gleam`: Main entry point and game loop orchestration.
- `game_logic.gleam`: Pure functional core handling state transitions and win conditions.
- `renderer.gleam`: I/O layer for terminal display and user input parsing.

## Features

- **Customizable Board Sizes**: Play on any N x N grid (min 3 for Standard, 4 for L-Shape).
- **Standard Mode**: Classic row, column, or diagonal completion.
- **L-Shape Mode**: A variant where players must complete an 'L' pattern. Given a pair permutation on rows and columns respectively (n - 1) (n - 2)

## L-Shape Mode

In this mode, the win condition is completing an L-shaped path on the board. The size of the L-shape scales with the board size (2N-4 cells).

## Usage

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

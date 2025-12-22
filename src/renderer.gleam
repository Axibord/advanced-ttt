import game_logic.{
  type GameMode, type GameState, type Player, LShape, O, Standard, X,
}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import input.{input}

pub fn render_board(state: GameState) {
  let range = list.range(0, state.size - 1)
  list.each(range, fn(r) {
    let row_str =
      list.map(range, fn(c) {
        case dict.get(state.board, #(r, c)) {
          Ok(X) -> " X "
          Ok(O) -> " O "
          Error(Nil) -> int.to_string(r) <> " " <> int.to_string(c)
        }
      })
      |> string.join(" | ")
    io.println(row_str)
    case r < state.size - 1 {
      True -> {
        let line =
          string.repeat("-----", state.size)
          <> string.repeat("-", state.size - 2)
        io.println(line)
      }
      False -> Nil
    }
  })
}

pub fn get_player_input() -> Result(#(Int, Int), String) {
  use line <- result.try(
    input(prompt: "Enter row and col (e.g. 0 1): ")
    |> result.replace_error("Failed to read input"),
  )
  let parts =
    string.split(line, " ")
    |> list.filter(fn(s) { s != "" })

  case parts {
    [r_str, c_str] -> {
      case int.parse(r_str), int.parse(c_str) {
        Ok(r), Ok(c) -> Ok(#(r, c))
        _, _ -> Error("Invalid numbers. Please enter integers.")
      }
    }
    _ -> Error("Please enter exactly two numbers separated by a space.")
  }
}

pub fn get_player_name(prompt_prefix: String) -> String {
  case input(prompt: prompt_prefix <> " name: ") {
    Ok(name) ->
      case string.trim(name) {
        "" -> get_player_name(prompt_prefix)
        trimmed -> trimmed
      }
    Error(_) -> get_player_name(prompt_prefix)
  }
}

pub fn get_game_mode() -> GameMode {
  io.println("Select Game Mode:")
  io.println("1. Standard")
  io.println("2. LShape")

  case input(prompt: "Enter choice (1 or 2): ") {
    Ok("1") -> Standard
    Ok("2") -> LShape
    _ -> {
      io.println("Invalid choice. Please enter 1 or 2.")
      get_game_mode()
    }
  }
}

pub fn get_board_size(mode: GameMode) -> Int {
  let min_size = case mode {
    Standard -> 3
    LShape -> 4
  }

  case
    input(prompt: "Enter board size (min " <> int.to_string(min_size) <> "): ")
  {
    Ok(s) -> {
      case int.parse(s) {
        Ok(n) if n >= min_size -> n
        _ -> {
          io.println(
            "Invalid size. Must be an integer >= " <> int.to_string(min_size),
          )
          get_board_size(mode)
        }
      }
    }
    Error(_) -> get_board_size(mode)
  }
}

pub fn player_to_string(state: GameState, p: Player) -> String {
  case dict.get(state.player_names, p) {
    Ok(name) -> name
    Error(_) ->
      case p {
        X -> "X"
        O -> "O"
      }
  }
}

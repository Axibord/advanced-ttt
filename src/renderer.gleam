import game_logic.{type GameState, type Player, O, X}
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

pub fn player_to_string(p: Player) -> String {
  case p {
    X -> "X"
    O -> "O"
  }
}

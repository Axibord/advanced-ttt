import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import input.{input}

pub type Player {
  X
  O
}

pub type GameStatus {
  Ongoing
  Won(Player)
  Draw
}

pub type Cell {
  Occupied(Player)
  Empty
}

pub type Board =
  List(List(Cell))

pub type GameState {
  GameState(
    rows: Dict(Int, Int),
    cols: Dict(Int, Int),
    diag: Int,
    diag_reverse: Int,
  )
}

pub type Coordinate =
  #(Int, Int)

pub type UserInput {
  UserInput(n: Int, k: Int, player: Player)
}

pub fn increment(value: Option(Int)) {
  case value {
    Some(v) -> v + 1
    None -> 1
  }
}

pub fn check_win(
  game_state: GameState,
  user_input: UserInput,
  size: Int,
) -> GameStatus {
  // increment count for giving row and col
  dict.upsert(game_state.rows, user_input.n, increment)
  dict.upsert(game_state.cols, user_input.k, increment)

  // increment diag if it's a diagonal position
  let game_state = case user_input.n == user_input.k {
    True -> GameState(..game_state, diag: game_state.diag + 1)
    False -> game_state
  }

  // increment the reverse diag if it's a reverse diagonal position
  let game_state = case int.absolute_value(user_input.n - user_input.k) == 1 {
    True -> GameState(..game_state, diag_reverse: game_state.diag_reverse + 1)
    False -> game_state
  }

  let GameState(rows, cols, diag, diag_reverse) = game_state

  let won_horiz = case dict.get(rows, user_input.n) {
    Ok(value) -> value == size
    Error(Nil) -> False
  }

  let won_verti = case dict.get(cols, user_input.k) {
    Ok(value) -> value == size
    Error(Nil) -> False
  }

  let won_diag = diag == size
  let won_diag_reverse = diag_reverse == size

  case won_horiz || won_verti || won_diag || won_diag_reverse {
    True -> Won(user_input.player)
    False -> Ongoing
  }
}

pub fn main() {
  io.println("Hello from tic_tac_toe!")
  let assert Ok(my_input) = input(prompt: "> ")
  echo my_input
}

import gleam/dict.{type Dict}
import gleam/option.{type Option, None, Some}

pub type Player {
  X
  O
}

pub type GameStatus {
  Ongoing
  Won(Player)
  Draw
}

pub type Coordinate =
  #(Int, Int)

pub type PlayerStats {
  PlayerStats(
    rows: Dict(Int, Int),
    cols: Dict(Int, Int),
    diag: Int,
    diag_reverse: Int,
  )
}

pub type GameState {
  GameState(
    x_stats: PlayerStats,
    o_stats: PlayerStats,
    board: Dict(Coordinate, Player),
    size: Int,
    current_player: Player,
    moves_count: Int,
  )
}

fn increment(value: Option(Int)) {
  case value {
    Some(v) -> v + 1
    None -> 1
  }
}

pub fn place_piece(
  state: GameState,
  coord: Coordinate,
) -> Result(GameState, String) {
  let #(row, col) = coord

  let is_out_of_bounds =
    row < 0 || row >= state.size || col < 0 || col >= state.size

  case is_out_of_bounds {
    True -> Error("Coordinates out of bounds")
    False -> {
      // Check if occupied
      case dict.get(state.board, coord) {
        Ok(_) -> Error("Cell already occupied")
        Error(Nil) -> {
          let player = state.current_player
          let stats = case player {
            X -> state.x_stats
            O -> state.o_stats
          }

          // Update player stats
          let new_rows = dict.upsert(stats.rows, row, increment)
          let new_cols = dict.upsert(stats.cols, col, increment)
          let new_diag = case row == col {
            True -> stats.diag + 1
            False -> stats.diag
          }
          let new_diag_reverse = case row + col == state.size - 1 {
            True -> stats.diag_reverse + 1
            False -> stats.diag_reverse
          }

          let new_player_stats =
            PlayerStats(new_rows, new_cols, new_diag, new_diag_reverse)

          let new_board = dict.insert(state.board, coord, player)
          let new_moves_count = state.moves_count + 1

          let new_state = case player {
            X ->
              GameState(
                ..state,
                x_stats: new_player_stats,
                board: new_board,
                moves_count: new_moves_count,
              )
            O ->
              GameState(
                ..state,
                o_stats: new_player_stats,
                board: new_board,
                moves_count: new_moves_count,
              )
          }

          Ok(new_state)
        }
      }
    }
  }
}

pub fn check_game_status(state: GameState, last_move: Coordinate) -> GameStatus {
  let #(row, col) = last_move
  let player = case dict.get(state.board, last_move) {
    Ok(p) -> p
    Error(Nil) -> state.current_player
  }

  let stats = case player {
    X -> state.x_stats
    O -> state.o_stats
  }

  let won =
    dict.get(stats.rows, row) == Ok(state.size)
    || dict.get(stats.cols, col) == Ok(state.size)
    || stats.diag == state.size
    || stats.diag_reverse == state.size

  case won {
    True -> Won(player)
    False -> {
      case state.moves_count == state.size * state.size {
        True -> Draw
        False -> Ongoing
      }
    }
  }
}

pub fn switch_player(state: GameState) -> GameState {
  let next_player = case state.current_player {
    X -> O
    O -> X
  }
  GameState(..state, current_player: next_player)
}

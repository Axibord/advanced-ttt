import gleam/dict.{type Dict}
import gleam/list
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

pub type GameMode {
  Standard
  LShape
}

pub type Coordinate =
  #(Int, Int)

type LShapes =
  Dict(Int, List(Coordinate))

type LShapesCounter =
  Dict(Int, Int)

pub type PlayerStats {
  PlayerStats(
    rows: Dict(Int, Int),
    cols: Dict(Int, Int),
    l_shapes_counter: LShapesCounter,
    diag: Int,
    diag_reverse: Int,
  )
}

pub type GameState {
  GameState(
    x_stats: PlayerStats,
    o_stats: PlayerStats,
    board: Dict(Coordinate, Player),
    l_shapes: LShapes,
    size: Int,
    current_player: Player,
    mode: GameMode,
    moves_count: Int,
    player_names: Dict(Player, String),
  )
}

pub fn play_turn(
  game_state: GameState,
  coord: Coordinate,
) -> Result(GameState, String) {
  let #(r, c) = coord

  let is_out_of_bounds =
    r < 0 || r >= game_state.size || c < 0 || c >= game_state.size

  case is_out_of_bounds {
    True -> Error("Coordinates out of bounds")
    False -> {
      case dict.get(game_state.board, coord) {
        Ok(_) -> Error("Cell already occupied")
        Error(Nil) -> {
          let player = game_state.current_player
          let player_stats = case player {
            X -> game_state.x_stats
            O -> game_state.o_stats
          }
          let size = game_state.size

          let updated_player_stats =
            update_stats(game_state, player_stats, #(r, c), size)

          let new_board = dict.insert(game_state.board, coord, player)
          let new_moves_count = game_state.moves_count + 1

          let updated_game_state = case player {
            X ->
              GameState(
                ..game_state,
                x_stats: updated_player_stats,
                board: new_board,
                moves_count: new_moves_count,
              )
            O ->
              GameState(
                ..game_state,
                o_stats: updated_player_stats,
                board: new_board,
                moves_count: new_moves_count,
              )
          }

          Ok(updated_game_state)
        }
      }
    }
  }
}

fn update_stats(
  game_state: GameState,
  player_stats: PlayerStats,
  coord: Coordinate,
  size: Int,
) {
  case game_state.mode {
    Standard -> {
      let #(row, col) = coord
      let rows = dict.upsert(player_stats.rows, row, increment)
      let cols = dict.upsert(player_stats.cols, col, increment)
      let diag = case row == col {
        True -> player_stats.diag + 1
        False -> player_stats.diag
      }
      let diag_reverse = case row + col == size - 1 {
        True -> player_stats.diag_reverse + 1
        False -> player_stats.diag_reverse
      }

      PlayerStats(..player_stats, rows:, cols:, diag:, diag_reverse:)
    }

    LShape -> {
      let l_shapes_counter =
        increment_count_matching_l_shapes(
          coord,
          player_stats.l_shapes_counter,
          game_state.l_shapes,
        )
      PlayerStats(..player_stats, l_shapes_counter:)
    }
  }
}

pub fn check_game_status(
  game_state: GameState,
  last_move: Coordinate,
) -> GameStatus {
  let #(row, col) = last_move
  let player = case dict.get(game_state.board, last_move) {
    Ok(p) -> p
    Error(Nil) -> game_state.current_player
  }

  let player_stats = case player {
    X -> game_state.x_stats
    O -> game_state.o_stats
  }

  let won = {
    case game_state.mode {
      Standard -> {
        dict.get(player_stats.rows, row) == Ok(game_state.size)
        || dict.get(player_stats.cols, col) == Ok(game_state.size)
        || player_stats.diag == game_state.size
        || player_stats.diag_reverse == game_state.size
      }
      LShape ->
        has_completed_l_shape(player_stats.l_shapes_counter, game_state.size)
    }
  }

  case won {
    True -> Won(player)
    False -> {
      case game_state.moves_count == game_state.size * game_state.size {
        True -> Draw
        False -> Ongoing
      }
    }
  }
}

fn has_completed_l_shape(lshapes_counter: LShapesCounter, size: Int) -> Bool {
  let l_size = { 2 * size } - 4
  lshapes_counter
  |> dict.values()
  |> list.any(fn(v) { v == l_size })
}

fn increment_count_matching_l_shapes(
  coord: Coordinate,
  l_shapes_counter: LShapesCounter,
  l_shapes: LShapes,
) -> LShapesCounter {
  use l_shapes_counter, l_shape_id, l_shape_coords <- dict.fold(
    over: l_shapes,
    from: l_shapes_counter,
  )

  let is_part_of_lshape = list.contains(l_shape_coords, coord)

  case is_part_of_lshape {
    True -> dict.upsert(l_shapes_counter, l_shape_id, increment)
    False -> l_shapes_counter
  }
}

pub fn build_l_shapes(size: Int) -> LShapes {
  let coords = build_coordinates(size)

  let all_paths = {
    use coord <- list.flat_map(coords)
    let arrival_coords = calculate_l_arrival_coords(coord, size)
    generate_l_paths(coord, arrival_coords)
  }

  use l_shapes, path, l_shape_id <- list.index_fold(all_paths, dict.new())
  dict.insert(l_shapes, l_shape_id, path)
}

fn generate_l_paths(
  start: Coordinate,
  arrivals: List(Coordinate),
) -> List(List(Coordinate)) {
  let #(r_start, c_start) = start
  use arrival_coord <- list.flat_map(arrivals)

  let #(r_end, c_end) = arrival_coord

  // Horizontal then Vertical
  let path_a =
    list.flatten([
      list.range(c_start, c_end) |> list.map(fn(c) { #(r_start, c) }),
      list.range(r_start, r_end)
        |> list.filter(fn(r) { r != r_start })
        |> list.map(fn(r) { #(r, c_end) }),
    ])

  // Vertical then Horizontal
  let path_b =
    list.flatten([
      list.range(r_start, r_end) |> list.map(fn(r) { #(r, c_start) }),
      list.range(c_start, c_end)
        |> list.filter(fn(c) { c != c_start })
        |> list.map(fn(c) { #(r_end, c) }),
    ])

  [path_a, path_b]
}

fn calculate_l_arrival_coords(coord: Coordinate, size: Int) -> List(Coordinate) {
  let #(r, c) = coord
  let d1 = size - 2
  let d2 = size - 3
  // from any point (r,c) we can have a max of 8 moves
  let moves: List(Coordinate) = [
    #(d1, d2),
    #(d1, -d2),
    #(-d1, d2),
    #(-d1, -d2),
    #(d2, d1),
    #(d2, -d1),
    #(-d2, d1),
    #(-d2, -d1),
  ]

  moves
  |> list.map(fn(move) { #(r + move.0, c + move.1) })
  |> list.filter(fn(coord) {
    { coord.0 >= 0 && coord.0 < size } && { coord.1 >= 0 && coord.1 < size }
  })
}

fn build_coordinates(size: Int) -> List(Coordinate) {
  let pairs_1 = list.range(0, size - 1)
  let pairs_2 = list.reverse(pairs_1)
  let combinations_1 = list.combination_pairs(pairs_1)
  let combinations_2 = list.combination_pairs(pairs_2)
  let diag = list.map(list.range(0, size - 1), fn(i) { #(i, i) })

  combinations_1
  |> list.append(combinations_2)
  |> list.append(diag)
}

pub fn switch_player(state: GameState) -> GameState {
  let next_player = case state.current_player {
    X -> O
    O -> X
  }
  GameState(..state, current_player: next_player)
}

fn increment(value: Option(Int)) {
  case value {
    Some(v) -> v + 1
    None -> 1
  }
}

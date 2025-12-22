import game_logic
import gleam/dict
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn l_shape_bug_reproduction_test() {
  let size = 4
  let l_shapes = game_logic.build_l_shapes(size)
  let player_stats =
    game_logic.PlayerStats(
      rows: dict.new(),
      cols: dict.new(),
      l_shapes_counter: dict.new(),
      diag: 0,
      diag_reverse: 0,
    )

  let game_state =
    game_logic.GameState(
      x_stats: player_stats,
      o_stats: player_stats,
      board: dict.new(),
      l_shapes: l_shapes,
      size: size,
      current_player: game_logic.X,
      mode: game_logic.LShape,
      moves_count: 0,
      player_names: dict.new(),
    )

  // Moves: (0,0), (0,1), (1,1), (0,2)
  // (0,0) is start.
  // (0,1) is common to P1 (to 2,1) and P2 (to 1,2).
  // (1,1) is unique to P1.
  // (0,2) is unique to P2.
  // None of P1 or P2 is complete.
  // P1 needs (2,1).
  // P2 needs (1,2).
  let moves = [#(0, 0), #(0, 1), #(1, 1), #(0, 2)]

  let final_state_result =
    list.fold(moves, Ok(game_state), fn(state_result, move) {
      case state_result {
        Ok(state) -> game_logic.play_turn(state, move)
        Error(e) -> Error(e)
      }
    })

  let assert Ok(final_state) = final_state_result

  let status = game_logic.check_game_status(final_state, #(0, 2))

  // It should NOT be won.
  status
  |> should.equal(game_logic.Ongoing)
}

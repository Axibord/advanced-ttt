import game_logic.{
  type GameMode, type GameState, type PlayerStats, Draw, GameState, LShape,
  Ongoing, PlayerStats, Standard, Won, X,
}
import gleam/dict
import gleam/io
import gleam/result
import renderer

pub fn main() {
  io.println("Welcome to Advanced Tic-Tac-Toe!")
  let size = 3
  let game = init_game(size)
  game_loop(game)
}

fn init_stats() -> PlayerStats {
  PlayerStats(
    rows: dict.new(),
    cols: dict.new(),
    l_shapes_counter: dict.new(),
    diag: 0,
    diag_reverse: 0,
  )
}

fn init_game(size: Int) -> GameState {
  GameState(
    x_stats: init_stats(),
    o_stats: init_stats(),
    board: dict.new(),
    size: size,
    l_shapes: game_logic.build_l_shapes(size),
    current_player: X,
    mode: Standard,
    moves_count: 0,
  )
}

fn game_loop(state: GameState) {
  io.println("")
  renderer.render_board(state)
  io.println("")
  io.println(
    "Player " <> renderer.player_to_string(state.current_player) <> "'s turn.",
  )

  let played_turn = {
    use coord <- result.try(renderer.get_player_input())
    use new_state <- result.try(game_logic.play_turn(state, coord))
    Ok(#(new_state, coord))
  }

  case played_turn {
    Ok(#(new_state, coord)) -> {
      case game_logic.check_game_status(new_state, coord) {
        Ongoing -> game_loop(game_logic.switch_player(new_state))
        Won(player) -> {
          io.println("")
          renderer.render_board(new_state)
          io.println(
            "\nCongratulations! Player "
            <> renderer.player_to_string(player)
            <> " wins!",
          )
        }
        Draw -> {
          io.println("")
          renderer.render_board(new_state)
          io.println("\nIt's a draw!")
        }
      }
    }
    Error(err) -> {
      io.println("Error: " <> err)
      game_loop(state)
    }
  }
}

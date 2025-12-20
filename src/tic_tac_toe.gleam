import game_logic.{
  type GameState, type PlayerStats, Draw, GameState, Ongoing, PlayerStats, Won,
  X,
}
import gleam/dict
import gleam/io.{println}
import renderer

pub fn main() {
  io.println("Welcome to Tic-Tac-Toe!")
  let size = 3
  let game = init_game(size)
  game_loop(game)
}

fn init_stats() -> PlayerStats {
  PlayerStats(rows: dict.new(), cols: dict.new(), diag: 0, diag_reverse: 0)
}

fn init_game(size: Int) -> GameState {
  GameState(
    x_stats: init_stats(),
    o_stats: init_stats(),
    board: dict.new(),
    size: size,
    current_player: X,
    moves_count: 0,
  )
}

fn game_loop(state: GameState) {
  println("")
  renderer.render_board(state)
  println("")
  println(
    "Player " <> renderer.player_to_string(state.current_player) <> "'s turn.",
  )

  case renderer.get_player_input() {
    Ok(coord) -> {
      case game_logic.place_piece(state, coord) {
        Ok(new_state) -> {
          let status = game_logic.check_game_status(new_state, coord)
          case status {
            Ongoing -> game_loop(game_logic.switch_player(new_state))
            Won(p) -> {
              println("")
              renderer.render_board(new_state)
              println("")
              println(
                "Congratulations! Player "
                <> renderer.player_to_string(p)
                <> " wins!",
              )
            }
            Draw -> {
              println("")
              renderer.render_board(new_state)
              println("")
              println("It's a draw!")
            }
          }
        }
        Error(err) -> {
          println("Error: " <> err)
          game_loop(state)
        }
      }
    }
    Error(err) -> {
      println("Error: " <> err)
      game_loop(state)
    }
  }
}

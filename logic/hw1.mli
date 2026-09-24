type arrow_direction =
  | Left
  | Down
  | Up
  | Right

type note =
  { timestamp : float
  ; direction : arrow_direction
  }

type judgement =
  | Marvelous
  | Perfect
  | Great
  | Good
  | Miss

type decision =
  | In_progress
  | Stage_cleared of { final_score : int }
  | Stage_failed

type game_state =
  { upcoming_notes : note list
  ; life_bar : float
  ; score : int
  ; combo : int
  ; song_elapsed : float
  ; decision : decision
  }

type move =
  { key_pressed : arrow_direction
  ; press_time : float
  }

val evaluate_judgement : float -> judgement
val initial_state : game_state
val move_at_1_s : move
val state_after_move_at_1_s : game_state
val before_teminal_state : game_state
val move_to_terminal_state : move
val terminal_state : game_state

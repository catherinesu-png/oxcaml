open! Core

type arrow_direction =
  | Left
  | Down
  | Up
  | Right
[@@deriving sexp, compare, equal]

type note =
  { timestamp : float
  ; direction : arrow_direction
  }
[@@deriving sexp, compare, equal]

type judgement =
  | Marvelous
  | Perfect
  | Great
  | Good
  | Miss
[@@deriving sexp, compare, equal]

type decision =
  | In_progress
  | Stage_cleared of { final_score : int }
  | Stage_failed
[@@deriving sexp, compare, equal]

type game_state =
  { upcoming_notes : note list
  ; life_bar : float
  ; score : int
  ; combo : int
  ; song_elapsed : float
  ; decision : decision
  }
[@@deriving sexp, compare, equal]

type move =
  { key_pressed : arrow_direction
  ; press_time : float
  }
[@@deriving sexp, compare, equal]

val evaluate_judgement : float -> judgement
val update_time : game_state -> float -> game_state
val make_move : game_state -> move -> game_state

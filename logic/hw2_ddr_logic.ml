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

let evaluate_judgement (delta_time : float) : judgement = 
  let abs_delta = Float.abs delta_time in 
  if Float.(abs_delta <= 0.02) then Marvelous
  else if Float.(abs_delta <= 0.05) then Perfect 
  else if Float.(abs_delta <= 0.09) then Great 
  else if Float.(abs_delta <= 0.12) then Good
  else Miss
;; 

let score_delta_for_judgement = function
  | Marvelous -> 100
  | Perfect -> 80
  | Great -> 50 
  | Good -> 20 
  | Miss -> 0 
;; 

let life_delta_for_judgement = function
  | Marvelous -> 5.0
  | Perfect -> 3.0
  | Great -> 1.0
  | Good -> 0.0
  | Miss -> -10.0
;; 

let make_move (state: game_state) (move : move) : game_state = 
  match state.decision with 
  | Stage_cleared _ | Stage_failed -> state 
  | In_progress ->
    (match state.upcoming_notes with 
    | []-> state 
    | current_note :: remaining_notes ->
      let judgement =
         if equal_arrow_direction move.key_pressed current_note.direction then
           let delta_time = move.press_time -. current_note.timestamp in
           evaluate_judgement delta_time
         else
           Miss
       in
       let points = score_delta_for_judgement judgement in
       let life_diff = life_delta_for_judgement judgement in

       let new_score = state.score + points in
       let new_combo = match judgement with Miss -> 0 | _ -> state.combo + 1 in
       let new_life = Float.min 100.0 (state.life_bar +. life_diff) in

       let new_decision =
         if Float.(new_life <= 0.0) then
           Stage_failed
         else if List.is_empty remaining_notes then
           Stage_cleared { final_score = new_score }
         else
           In_progress
       in

       { upcoming_notes = remaining_notes
       ; life_bar = Float.max 0.0 new_life
       ; score = new_score
       ; combo = new_combo
       ; song_elapsed = move.press_time
       ; decision = new_decision
       })

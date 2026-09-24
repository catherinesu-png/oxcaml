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
  if Float.(abs_delta <= 0.02)
  then Marvelous
  else if Float.(abs_delta <= 0.05)
  then Perfect
  else if Float.(abs_delta <= 0.09)
  then Great
  else if Float.(abs_delta <= 0.12)
  then Good
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

let update_time (state : game_state) (current_time : float) : game_state =
  match state.decision with
  | Stage_cleared _ | Stage_failed -> state
  | In_progress ->
    let missed_notes, remaining_notes =
      List.partition_tf state.upcoming_notes ~f:(fun note ->
        Float.(current_time -. note.timestamp > 0.12))
    in
    if List.is_empty missed_notes
    then { state with song_elapsed = current_time }
    else (
      let miss_count = List.length missed_notes in
      let life_loss = Float.of_int miss_count *. life_delta_for_judgement Miss in
      let new_life = Float.max 0.0 (state.life_bar +. life_loss) in
      let new_decision =
        if Float.(new_life <= 0.0)
        then Stage_failed
        else if List.is_empty remaining_notes
        then Stage_cleared { final_score = state.score }
        else In_progress
      in
      { state with
        upcoming_notes = remaining_notes
      ; life_bar = new_life
      ; combo = 0
      ; song_elapsed = current_time
      ; decision = new_decision
      })
;;

let make_move (state : game_state) (move : move) : game_state =
  let state_at_move_time = update_time state move.press_time in
  match state_at_move_time.decision with
  | Stage_cleared _ | Stage_failed -> state_at_move_time
  | In_progress ->
    (match state_at_move_time.upcoming_notes with
     | [] -> state_at_move_time
     | current_note :: remaining_notes ->
       let delta_time = move.press_time -. current_note.timestamp in
       if Float.(delta_time < -0.12)
       then state_at_move_time
       else (
         let judgement =
           if equal_arrow_direction move.key_pressed current_note.direction
           then evaluate_judgement delta_time
           else Miss
         in
         let points = score_delta_for_judgement judgement in
         let life_diff = life_delta_for_judgement judgement in
         let new_score = state_at_move_time.score + points in
         let new_combo =
           match judgement with
           | Miss -> 0
           | _ -> state_at_move_time.combo + 1
         in
         let new_life = Float.min 100.0 (state_at_move_time.life_bar +. life_diff) in
         let new_decision =
           if Float.(new_life <= 0.0)
           then Stage_failed
           else if List.is_empty remaining_notes
           then Stage_cleared { final_score = new_score }
           else In_progress
         in
         { upcoming_notes = remaining_notes
         ; life_bar = Float.max 0.0 new_life
         ; score = new_score
         ; combo = new_combo
         ; song_elapsed = move.press_time
         ; decision = new_decision
         }))
;;

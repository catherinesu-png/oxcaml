open! Core

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

let evaluate_judgement (delta_time : float) : judgement = 
  let abs_delta = Float.abs delta_time in 
  if Float.(abs_delta <= 0.02) then Marvelous
  else if Float.(abs_delta <= 0.05) then Perfect 
  else if Float.(abs_delta <= 0.09) then Great 
  else if Float.(abs_delta <= 0.12) then Good
  else Miss
;; 
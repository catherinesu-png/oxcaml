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
   if abs_delta <= 0.02 then Marvelous
   else if abs_delta <= 0.05 then Perfect 
   else if abs_delta <= 0.09 then Great 
   else if abs_delta <= 0.12 then Good
   else Miss
;; 

let initial_state : game_state = 
  { upcoming_notes = 
       [ { timestamp = 1.0; direction = Left}
       ; { timestamp = 1.5; direction = Up}
       ; { timestamp = 2.0; direction = Down}]
  ; life_bar = 100.0
  ; score = 0
  ; combo = 0 
  ; song_elapsed = 0.0 
  ; decision = In_progress
  }
;;

let move_at_1_s : move = { key_pressed = Left; press_time = 1.0 }

let state_after_move_at_1_s : game_state = 
  { upcoming_notes = 
       [ { timestamp = 1.5; direction = Up}
       ; { timestamp = 2.0; direction = Down}]
  ; life_bar = 100.0
  ; score = 100
  ; combo = 1
  ; song_elapsed = 1.0 
  ; decision = In_progress
  }
;;

let before_teminal_state : game_state = 
  { upcoming_notes = 
       [ { timestamp = 2.0; direction = Down}]
  ; life_bar = 5.0
  ; score = 1000
  ; combo = 0
  ; song_elapsed = 44.5 
  ; decision = In_progress
  }
;;

let move_to_terminal_state : move = { key_pressed = Right; press_time = 46.0 } 

let terminal_state : game_state = 
  { upcoming_notes = 
       []
  ; life_bar = 0.0
  ; score = 1000
  ; combo = 0
  ; song_elapsed = 46.0
  ; decision = Stage_failed
  }
;;

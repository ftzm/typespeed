module Types exposing (..)

import Array
import Time
import List.Zipper
import Keyboard.Extra exposing (Key)

type GameState
  = PreStart
  | Running
  | Paused
  | Done

type alias KeyAttempt =
  { char : Char
  , correct : Bool
  }

type alias Model =
  { gameState : GameState
  , typed : List KeyAttempt
  , textList : Array.Array String
  , text : List.Zipper.Zipper Char
  , shift : Bool
  , startTime : Time.Time
  , pauseStart : Time.Time
  , stats : List (Float, Float) -- (wpm, acc)
  }

type alias Flags =
  { texts : List String
  }

type Msg = KeyUp Key
         | KeyDown Key
         | Start
         | SetStartTime Time.Time
         | Finish
         | CalcWpm Time.Time
         | RollText
         | NewText Int
         -- pause cycle
         | Pause
         | SetPauseStart Time.Time
         | Unpause Key
         | UnpauseAdjust Key Time.Time

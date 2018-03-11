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
  , wpms : List Float
  , acc : Float
  }

type alias Flags =
  { texts : List String
  }

type Msg = KeyUp Key
         | KeyDown Key
         | Start
         | SetStartTime Time.Time
         | Pause
         | Unpause
         | Finish
         | CalcWpm Time.Time
         | RollText
         | NewText Int

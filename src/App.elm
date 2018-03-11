module App exposing (main)

import Types exposing (..)
import View
import Html
import State

main : Program Flags Model Msg
main =
  Html.programWithFlags
    { init = State.init
    , view = View.view
    , update = State.update
    , subscriptions = State.subscriptions
    }

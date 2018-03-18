module App exposing (main)

import Html
import State
import Types exposing (..)
import View


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = State.init
        , view = View.view
        , update = State.update
        , subscriptions = State.subscriptions
        }

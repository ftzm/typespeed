module State exposing (init, subscriptions, update)

import Array
import Keyboard.Extra exposing (..)
import List.Zipper
import ParseKeys exposing (keyToChar)
import Random
import Task
import Time
import Types exposing (..)


------------------------------------------------------------
-- Subscriptions


subscriptions : Model -> Sub Types.Msg
subscriptions _ =
    Sub.batch
        [ Keyboard.Extra.downs Types.KeyDown
        , Keyboard.Extra.ups Types.KeyUp
        ]



------------------------------------------------------------
-- Init


init : Flags -> ( Model, Cmd Types.Msg )
init f =
    update RollText { initModel | textList = Array.fromList f.texts }


initModel : Model
initModel =
    { typed = []
    , textList = texts
    , text = zipperText "Start Text"
    , shift = False
    , gameState = PreStart
    , startTime = 0.0
    , pauseStart = 0.0
    , stats = []
    }


texts : Array.Array String
texts =
    Array.fromList
        [ "Sentence one."
        , "Sentence two."
        , "Sentence three."
        ]


zipperText : String -> List.Zipper.Zipper Char
zipperText s =
    List.Zipper.withDefault '!' <|
        List.Zipper.fromList <|
            String.toList s



------------------------------------------------------------
-- Update


update : Types.Msg -> Model -> ( Model, Cmd Types.Msg )
update msg =
    case msg of
        Types.KeyDown k ->
            handleDown k

        Types.KeyUp k ->
            handleUp k

        Start ->
            handleStart

        SetStartTime t ->
            handleSetStart t

        Finish ->
            handleFinish

        CalcWpm t ->
            handleWpm t

        RollText ->
            handleRollText

        NewText i ->
            handleNewText i

        Types.Pause ->
            handlePause

        SetPauseStart t ->
            handlePauseStart t

        Unpause k ->
            handleUnpause k

        UnpauseAdjust k t ->
            handleUnpauseAdjust k t


handleStart : Model -> ( Model, Cmd Types.Msg )
handleStart m =
    ( { m | gameState = Running }, Task.perform SetStartTime Time.now )


handleSetStart : Time.Time -> Model -> ( Model, Cmd Types.Msg )
handleSetStart t m =
    noCmd { m | startTime = t }


handleFinish : Model -> ( Model, Cmd Types.Msg )
handleFinish m =
    ( m, Task.perform CalcWpm Time.now )


handleWpm : Time.Time -> Model -> ( Model, Cmd Types.Msg )
handleWpm t m =
    let
        stats =
            ( calcWpm m.typed t m.startTime, calcAcc m.typed ) :: m.stats
    in
    noCmd { m | stats = stats, gameState = Done }


calcWpm : List KeyAttempt -> Time.Time -> Time.Time -> Float
calcWpm ks s e =
    let
        elapsed =
            Time.inMinutes <| s - e

        wordCount =
            (toFloat <| List.length ks) / 5
    in
    wordCount / elapsed


calcAcc : List KeyAttempt -> Float
calcAcc ks =
    let
        correct =
            toFloat <| List.length <| List.filter (\k -> k.correct) ks

        total =
            toFloat <| List.length ks
    in
    correct / total * 100


handleRollText : Model -> ( Model, Cmd Types.Msg )
handleRollText m =
    let
        randIndex =
            Random.int 0 (Array.length m.textList - 1)
    in
    ( m, Random.generate NewText randIndex )


handleNewText : Int -> Model -> ( Model, Cmd Types.Msg )
handleNewText i m =
    let
        newText =
            zipperText (Maybe.withDefault "Fail" <| Array.get i m.textList)
    in
    noCmd { m | text = newText, typed = [], gameState = PreStart }


handlePause : Model -> ( Model, Cmd Types.Msg )
handlePause m =
    ( { m | gameState = Paused }, Task.perform SetPauseStart Time.now )


handlePauseStart : Time.Time -> Model -> ( Model, Cmd Types.Msg )
handlePauseStart t m =
    noCmd { m | pauseStart = t }


handleUnpause : Key -> Model -> ( Model, Cmd Types.Msg )
handleUnpause k m =
    ( { m | gameState = Running }, Task.perform (UnpauseAdjust k) Time.now )


handleUnpauseAdjust : Key -> Time.Time -> Model -> ( Model, Cmd Types.Msg )
handleUnpauseAdjust k t m =
    handleDown k <| pauseAdjust t m


pauseAdjust : Time.Time -> Model -> Model
pauseAdjust t m =
    let
        offset =
            t - m.pauseStart
    in
    { m | startTime = m.startTime + offset }



------------------------------------------------------------
-- Keypress


handleDown : Key -> Model -> ( Model, Cmd Types.Msg )
handleDown k m =
    let
        maybeNewCharM =
            Maybe.map (addChar1 m) (keyToChar m.shift k)

        newCharM =
            Maybe.withDefault ( m, Cmd.none ) maybeNewCharM
    in
    case m.gameState of
        PreStart ->
            case k of
                Shift ->
                    noCmd { m | shift = True }

                _ ->
                    update Start (Tuple.first newCharM)

        Running ->
            case k of
                Escape ->
                    update Types.Pause m

                BackSpace ->
                    noCmd <| removeChar m

                Shift ->
                    noCmd <| { m | shift = True }

                _ ->
                    newCharM

        Paused ->
            update (Unpause k) m

        Done ->
            case k of
                Enter ->
                    update RollText m

                _ ->
                    noCmd m


handleUp : Key -> Model -> ( Model, Cmd Types.Msg )
handleUp k m =
    case k of
        Shift ->
            noCmd { m | shift = False }

        _ ->
            noCmd m


addChar1 : Model -> Char -> ( Model, Cmd Types.Msg )
addChar1 m c =
    let
        correct =
            c == List.Zipper.current m.text

        textAdded =
            { m | typed = { char = c, correct = correct } :: m.typed }

        nextModel =
            case List.Zipper.next m.text of
                Nothing ->
                    update Finish textAdded

                Just t ->
                    noCmd { textAdded | text = t }
    in
    nextModel


textForward : Model -> ( Model, Cmd Types.Msg )
textForward m =
    case List.Zipper.next m.text of
        Nothing ->
            update Finish m

        Just t ->
            noCmd { m | text = t }


addChar : Model -> Char -> Model
addChar m c =
    let
        correct =
            c == List.Zipper.current m.text
    in
    { m | typed = { char = c, correct = correct } :: m.typed }


removeChar : Model -> Model
removeChar m =
    let
        newText =
            List.Zipper.previous m.text

        nextModel =
            case newText of
                Nothing ->
                    m

                Just t ->
                    { m | typed = List.drop 1 m.typed, text = t }
    in
    nextModel



------------------------------------------------------------
-- Utility


noCmd : Model -> ( Model, Cmd Types.Msg )
noCmd m =
    ( m, Cmd.none )

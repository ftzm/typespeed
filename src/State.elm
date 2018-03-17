module State exposing (subscriptions, init, update)

import Types exposing (..)
import ParseKeys exposing (keyToChar)
import Keyboard.Extra exposing (..)
import Array
import List.Zipper
import Time
import Task
import Random

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

init : Flags -> (Model, Cmd Types.Msg)
--init f = ({ initModel | textList = Array.fromList f.texts}, Cmd.none)
init f = update RollText { initModel | textList = Array.fromList f.texts}

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
texts = Array.fromList
  [ "Sentence one."
  , "Sentence two."
  , "Sentence three."
  ]

zipperText : String -> List.Zipper.Zipper Char
zipperText s =  List.Zipper.withDefault '!'
          <| List.Zipper.fromList
          <| String.toList s

------------------------------------------------------------
-- Update

update : Types.Msg -> Model -> (Model, Cmd Types.Msg)
update msg m =
  case msg of
    Types.KeyDown k -> handleDown k m
    Types.KeyUp k -> handleUp k m
    Start -> ({ m | gameState = Running }, Task.perform SetStartTime Time.now)
    SetStartTime t -> ({ m | startTime = t }, Cmd.none)
    Finish -> (m, Task.perform CalcWpm Time.now)
    CalcWpm t -> ({ m | stats = (calcWpm m.typed t m.startTime, calcAcc m.typed) :: m.stats, gameState = Done }, Cmd.none)
    RollText -> (m, Random.generate NewText (Random.int 0 ((Array.length m.textList) - 1)))
    NewText i -> newText m i
    Types.Pause -> ({ m | gameState = Paused }, Task.perform SetPauseStart Time.now)
    SetPauseStart t -> ({ m | pauseStart = t }, Cmd.none)
    Unpause k -> ({ m | gameState = Running }, Task.perform (UnpauseAdjust k) Time.now)
    UnpauseAdjust k t -> handleDown k <| pauseAdjust t m

pauseAdjust : Time.Time -> Model -> Model
pauseAdjust t m =
    let
        offset = t - m.pauseStart
    in
        { m | startTime = m.startTime + offset}

avg : List Float -> Float
avg list = case list of
  [] -> 0
  _  -> (list |> List.sum ) / (list |> List.length |> toFloat)

--avgWpm : Model -> Float
--avgWpm m = avg m.wpms

calcWpm : (List KeyAttempt) -> Time.Time -> Time.Time -> Float
calcWpm ks s e =
  let
    elapsed = Time.inMinutes <| s - e
    wordCount = (toFloat <| List.length ks) / 5
  in wordCount / elapsed

calcAcc : (List KeyAttempt) -> Float
calcAcc ks =
  let
    correct = toFloat <| List.length <| List.filter (\k -> k.correct) ks
    total = toFloat <| List.length ks
  in
    correct / total * 100

newText : Model -> Int -> (Model, Cmd Types.Msg)
newText m i = ({ m | text = zipperText (Maybe.withDefault "Fail" <| Array.get i m.textList) , typed = [], gameState = PreStart }, Cmd.none)

handleDown : Key -> Model -> (Model, Cmd Types.Msg)
handleDown k m =
  let s = m.gameState
  in case s of
    PreStart -> case k of
      Shift -> ({ m | shift = True }, Cmd.none)
      _ -> update Start (Maybe.withDefault m (Maybe.map (Tuple.first << (addChar1 m)) (keyToChar m.shift k)))
    Running -> case k of
      Escape -> update Types.Pause m
      BackSpace -> (removeChar m, Cmd.none)
      Shift -> ({ m | shift = True }, Cmd.none)
      _ -> Maybe.withDefault (m, Cmd.none) (Maybe.map (addChar1 m) (keyToChar m.shift k))
    Paused -> update (Unpause k) m
    Done -> case k of
      Enter -> update RollText m
      _ -> (m, Cmd.none)

handleUp : Key -> Model -> (Model, Cmd Types.Msg)
handleUp k m =
    case k of
      Shift -> ({ m | shift = False }, Cmd.none)
      _     -> (m, Cmd.none)

addChar1 : Model -> Char -> (Model, Cmd Types.Msg)
addChar1 m c =
  let
    correct = c == List.Zipper.current m.text
    textAdded = { m | typed = {char = c , correct = correct} :: m.typed}
    nextModel = case List.Zipper.next m.text of
      Nothing -> update Finish textAdded
      Just t -> ({ textAdded |  text = t }, Cmd.none)
  in nextModel

textForward : Model -> (Model, Cmd Types.Msg)
textForward m = case List.Zipper.next m.text of
      Nothing -> update Finish m
      Just t -> ({ m |  text = t }, Cmd.none)

addChar : Model -> Char -> Model
addChar m c =
  let
    correct = c == List.Zipper.current m.text
  in
    { m | typed = {char = c , correct = correct} :: m.typed}

removeChar : Model -> Model
removeChar m =
  let
    newText = List.Zipper.previous m.text
    nextModel = case newText of
      Nothing -> m
      Just t -> { m | typed = (List.drop 1 m.typed), text = t }
  in nextModel

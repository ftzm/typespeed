module State exposing (subscriptions, init, update)

import Types exposing (..)
import Keyboard.Extra exposing (..)
import Array
import List.Zipper
import Time
import Task
import Random
import Char

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
init f = ({ initModel | textList = Array.fromList f.texts}, Cmd.none)

initModel : Model
initModel =
  { typed = []
  , textList = texts
  , text = zipperText "Start Text"
  , shift = False
  , gameState = PreStart
  , startTime = 0.0
  , wpms = []
  , acc = 0.0
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
update msg model =
  case msg of
    Types.KeyDown k -> handleDown k model
    Types.KeyUp k -> handleUp k model
    Start -> ({ model | gameState = Running }, Task.perform SetStartTime Time.now)
    SetStartTime t -> ({ model | startTime = t }, Cmd.none)
    Finish -> (model, Task.perform CalcWpm Time.now)
    CalcWpm t -> ({ model | wpms = (calcWpm model.typed t model.startTime) :: model.wpms, acc = calcAcc model.typed, gameState = Done }, Cmd.none)
    RollText -> (model, Random.generate NewText (Random.int 0 2))
    NewText i -> newText model i
    _ -> (model, Cmd.none)

--updateRunning : Msg -> Model -> (Model, Cmd Msg)
--updateRunning msg model = case msg of
--  Finish -> (model, Task.perform CalcWpm Time.now)
--  _ -> (model, Cmd.none)

avg : List Float -> Float
avg list = case list of
  [] -> 0
  _  -> (list |> List.sum ) / (list |> List.length |> toFloat)

avgWpm : Model -> Float
avgWpm m = avg m.wpms

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
    correct / total

newText : Model -> Int -> (Model, Cmd Types.Msg)
newText m i = ({ m | text = zipperText (Maybe.withDefault "Fail" <| Array.get i m.textList) , typed = [], gameState = PreStart }, Cmd.none)

handleDown : Key -> Model -> (Model, Cmd Types.Msg)
handleDown k m =
  let s = m.gameState
  in case s of
    PreStart -> case k of
      Enter -> update Start m
      _ -> (m, Cmd.none)
    Running -> case k of
      BackSpace -> (removeChar m, Cmd.none)
      Shift -> ({ m | shift = True }, Cmd.none)
      _ -> Maybe.withDefault (m, Cmd.none) (Maybe.map (addChar m) (keyToChar m.shift k))
    Done -> case k of
      Enter -> update RollText m
      _ -> (m, Cmd.none)
    _ -> (m, Cmd.none)

handleUp : Key -> Model -> (Model, Cmd Types.Msg)
handleUp k m =
    case k of
      Shift -> ({ m | shift = False }, Cmd.none)
      _     -> (m, Cmd.none)

addChar : Model -> Char -> (Model, Cmd Types.Msg)
addChar m c =
  let
    correct = c == List.Zipper.current m.text
    nextText = List.Zipper.next m.text
    nextModel = case nextText of
      Nothing -> update Finish { m | typed = {char = c , correct = correct} :: m.typed}
      Just t -> ({ m | typed = {char = c , correct = correct} :: m.typed, text = t }, Cmd.none)
  in nextModel

removeChar : Model -> Model
removeChar m =
  let
    newText = List.Zipper.previous m.text
    nextModel = case newText of
      Nothing -> m
      Just t -> { m | typed = (List.drop 1 m.typed), text = t }
  in nextModel

keyToChar : Bool -> Key -> Maybe Char
keyToChar shift k =
 let char = case k of
   CharA -> Just 'a'
   CharB -> Just 'b'
   CharC -> Just 'c'
   CharD -> Just 'd'
   CharE -> Just 'e'
   CharF -> Just 'f'
   CharG -> Just 'g'
   CharH -> Just 'h'
   CharI -> Just 'i'
   CharJ -> Just 'j'
   CharK -> Just 'k'
   CharL -> Just 'l'
   CharM -> Just 'm'
   CharN -> Just 'n'
   CharO -> Just 'o'
   CharP -> Just 'p'
   CharQ -> Just 'q'
   CharR -> Just 'r'
   CharS -> Just 's'
   CharT -> Just 't'
   CharU -> Just 'u'
   CharV -> Just 'v'
   CharW -> Just 'w'
   CharX -> Just 'x'
   CharY -> Just 'y'
   CharZ -> Just 'z'
   Space -> Just ' '
   Period -> Just '.'
   _     -> Nothing
 in if shift then Maybe.map Char.toUpper char else char

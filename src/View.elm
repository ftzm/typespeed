module View exposing (view)

import Types exposing (..)
import Chart exposing (..)
import Html exposing (..)
import Html.Attributes exposing (href, title, class)
import Round
import List.Zipper

view : Model -> Html Msg
view m =
  let content = case m.gameState of
    Done -> viewDone m
    --PreStart -> viewPreStart m
    PreStart -> viewTypeage m
    _ -> viewTypeage m
  in
    div [class "grid-wrapper"]
      [ div [class "item-a logo-container"] [logo]
      , div [class "item-b info-container"] [performance m]
      , content
      , div [class "item-e credit"] [span [] [text "Written by ", a [href "#"] [text "Matthew Fitzsimmons"], br [] [], text "as an exercise in ", a [href "#"] [text "Elm."]]]
      , div [class "item-f instructions"] [instructions m]
      ]



logo : Html Msg
logo = div [class "logo"] [text "TypeSpeed"]

viewPreStart : Model -> Html Msg
viewPreStart m = div [class "main-container"] [div [class "main"] [text "Press enter to begin"]]

viewDone : Model -> Html Msg
viewDone m =
    let
        w = Maybe.withDefault 0 (Maybe.map Tuple.first <| List.head m.stats)
        wt = text <| Round.round 0 w ++ " Words per minute, with "
        wm = text <| if w > 70 then
                 "You're flying!"
             else if w > 50 then
                 "You're getting fast!"
             else if w > 40 then
                 "Solid Speed."
             else if w > 30 then
                 "A workable speed."
             else
                 "Keep Trying."
        a = Maybe.withDefault 0 (Maybe.map Tuple.second <| List.head m.stats)
        at = text <| Round.round 0 a ++ " percent accuracy. "
        am = text <| if a == 100 then
                 " Perfect Accuracy!"
             else if a > 95 then
                 " Good Accuracy."
             else
                 " Work or your accuracy."
    in
        div [class "main-container"] [ div [class "main"] [wt, at, wm, am]]

takeLast : Int -> List a -> List a
takeLast n l = List.reverse <| List.take n <| List.reverse <| l

viewTypeage : Model -> Html Msg
viewTypeage m =
  let
    l = m.text
    ks = m.typed
    typedText = List.map (\k -> span (if k.correct then [] else [class "wrong"]) [text <| String.fromList [k.char]]) <| List.reverse <| List.take 30 ks
    pastText = text <| String.fromList <| takeLast 30 <| List.Zipper.before l
    past = [div [class "vert-flex"] [pastText, br [] [], div [] typedText, div [class "leftGrad"] [text " "]]]
    presentText = text <| String.fromList <| [List.Zipper.current l]
    futureText = text <| String.fromList <| List.take 1000 <| List.Zipper.after l
    future = [div [class "vert-flex future"] [presentText, futureText, br [] [], span [class "cursor"] [text " "], div [class "rightGrad"] [text " "]]]

  in
    div [class "item-c typeage"] [div [class "item-a past vert-flex-wrapper"] past, div [class "item-b future vert-flex-wrapper"] future]

instructions : Model -> Html Msg
instructions m =
    let
        i = text <| case m.gameState of
                PreStart -> "Begin typing to start the test."
                Running -> "Press Escape to pause."
                Paused -> "Press any key to resume typing."
                Done -> "Press Enter to continue."
        p = span [Html.Attributes.style [("color", "rgba(255, 0, 0 ,0.5)"), ("font-weight", "bold")]] [text "> "]
    in
        div [] [p, i]

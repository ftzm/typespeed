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
    PreStart -> viewPreStart m
    _ -> viewTypeage m
  in
    div [class "grid-wrapper"]
      [ div [class "item-a logo-container"] [logo]
      , div [class "item-b info-container"] [performance m]
      , content
      , div [class "item-e logo-container"] [text " "]
      , div [class "item-f info-container"] [text " "]
      ]

logo : Html Msg
logo = div [class "logo"] [text "TypeSpeed"]

viewPreStart : Model -> Html Msg
viewPreStart m = div [class "main-container"] [div [class "main"] [text "Press enter to begin"]]

viewDone : Model -> Html Msg
viewDone m =
  div [class "main-container"]
    [ div [class "main"]
        [ text "WPM: "
        , text <| Round.round 2 (Maybe.withDefault  0 (List.head m.wpms))
        , text " Accuracy: "
        , text <| Round.round 2 m.acc
        ]
    ]

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
    future = [div [class "vert-flex future"] [presentText, futureText, br [] [], span [class "cursor"] [text "_"], div [class "rightGrad"] [text " "]]]

  in
    div [class "item-c typeage"] [div [class "item-a past vert-flex-wrapper"] past, div [class "item-b future vert-flex-wrapper"] future]

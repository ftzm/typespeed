module Chart exposing (performance)

import Html exposing (..)
import Html.Attributes exposing (class, href, title)
import Plot exposing (..)
import Round
import Svg.Attributes exposing (stroke)
import Types exposing (..)


-- interpolation will have to be Linear when there are only two points and monotone over that.


customLine : Model -> Series (List ( Float, Float )) msg
customLine m =
    let
        strokeStyle =
            if List.length m.wpms > 2 then
                Monotone
            else
                Linear
    in
    { axis = clearAxis
    , interpolation = strokeStyle Nothing [ stroke blueStroke ]
    , toDataPoints = List.map blueCircle
    }


blueCircle : ( Float, Float ) -> DataPoint msg
blueCircle ( x, y ) =
    dot (viewCircle 5 blueStroke) x (y * 1.2)


blueStroke : String
blueStroke =
    "#777777"


data : List ( Float, Float )
data =
    [ ( -2, 10 ), ( -1, 20 ), ( -0.5, -5 ), ( 0, 10 ), ( 0.5, 20 ), ( 1, -5 ), ( 1.5, 4 ), ( 2, -7 ), ( 2.5, 5 ), ( 3, 20 ), ( 3.5, 7 ), ( 4, 28 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 10 ), ( 1, 20 ) ]


wpmData : Model -> List ( Float, Float )
wpmData m =
    List.indexedMap (\x -> \y -> ( toFloat x, y )) <| List.reverse m.wpms


wpm : String -> Html Msg
wpm s =
    div
        [ class "wpm" ]
        [ text "AVG"
        , br [] []
        , text "WPM"
        , br [] []
        , text s
        ]


performance : Model -> Html Msg
performance m =
    let
        chart =
            viewSeriesCustom
                { defaultSeriesPlotCustomizations
                    | height = 100
                    , horizontalAxis = clearAxis
                }
                [ customLine m
                ]
                (wpmData m)
    in
    div [ class "statBox" ] [ wpm <| Round.round 0 <| avgWpm m, div [] [ chart ] ]


avg : List Float -> Float
avg list =
    case list of
        [] ->
            0

        _ ->
            (list |> List.sum) / (list |> List.length |> toFloat)


avgWpm : Model -> Float
avgWpm m =
    avg m.wpms

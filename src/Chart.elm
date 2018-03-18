module Chart exposing (chart)

import Html exposing (..)
import Plot exposing (..)
import Svg.Attributes exposing (stroke)
import Types exposing (..)


-- interpolation will have to be Linear when there are only two points and monotone over that.


customLine : Model -> Series (List ( Float, Float )) msg
customLine m =
    let
        strokeStyle =
            if List.length m.stats == 2 then
                Linear
            else
                Monotone
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


mockData : List ( Float, Float )
mockData =
    [ ( -1.5, 10 ), ( -1, 20 ), ( -0.5, -5 ), ( 0, 10 ), ( 0.5, 20 ), ( 1, -5 ), ( 1.5, 4 ), ( 2, -7 ), ( 2.5, 5 ), ( 3, 20 ), ( 3.5, 7 ), ( 4, 28 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 10 ), ( 1, 20 ) ]


wpmData : Model -> List ( Float, Float )
wpmData m =
    List.indexedMap (\x -> \( y, _ ) -> ( toFloat x, y )) <| List.reverse m.stats


chart : Model -> Html Msg
chart m =
    let
        data =
            if wpmData m == [] then
                mockData
            else
                wpmData m
    in
    viewSeriesCustom
        { defaultSeriesPlotCustomizations
            | height = 100
            , horizontalAxis = clearAxis
        }
        [ customLine m
        ]
        data

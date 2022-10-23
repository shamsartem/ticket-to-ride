module Page.Index exposing
    ( Model
    , Msg
    , getStore
    , init
    , setStore
    , subscriptions
    , update
    , view
    )

import Attributes exposing (ariaHidden, ifAttr, inputmode)
import Html exposing (..)
import Html.Attributes exposing (checked, class, disabled, for, id, name, pattern, placeholder, type_, value)
import Html.Events exposing (onCheck, onClick, onInput, onSubmit)
import Store exposing (Store)


baseClass : String
baseClass =
    "Index"


cl : String -> String
cl elementAndOrModifier =
    baseClass ++ "_" ++ elementAndOrModifier


c : String -> Attribute msg
c elementAndOrModifier =
    class (cl elementAndOrModifier)


type Color
    = Red
    | Blue
    | Green
    | Yellow
    | Black


colorToString : Color -> String
colorToString color =
    case color of
        Red ->
            "red"

        Blue ->
            "blue"

        Green ->
            "green"

        Yellow ->
            "yellow"

        Black ->
            "black"


type Longest
    = Color Color
    | Unknown


type alias Route =
    { points : Int
    , completed : Bool
    }


type Counter
    = Station
    | One
    | Two
    | Three
    | Four
    | Six
    | Eight


conunterToStringCount : Counter -> String
conunterToStringCount counter =
    case counter of
        Station ->
            "S"

        One ->
            "1"

        Two ->
            "2"

        Three ->
            "3"

        Four ->
            "4"

        Six ->
            "6"

        Eight ->
            "8"


type alias Player =
    { color : Color
    , stations : Int
    , ones : Int
    , twos : Int
    , threes : Int
    , fours : Int
    , sixes : Int
    , eights : Int
    , routes : List Route
    , completed : Bool
    , routeInput : String
    }


type alias Model =
    { store : Store
    , longest : Longest
    , red : Player
    , blue : Player
    , green : Player
    , yellow : Player
    , black : Player
    , currentPlayerColor : Color
    }


getStore : Model -> Store
getStore model =
    model.store


setStore : Store -> Model -> Model
setStore store model =
    { model | store = store }


getPlayerByColor : Model -> Color -> Player
getPlayerByColor model color =
    case color of
        Red ->
            model.red

        Blue ->
            model.blue

        Green ->
            model.green

        Yellow ->
            model.yellow

        Black ->
            model.black


init : Store -> ( Model, Cmd Msg )
init store =
    ( { store = store
      , longest = Unknown
      , red = Player Red 0 0 0 0 0 0 0 [] True ""
      , blue = Player Blue 0 0 0 0 0 0 0 [] True ""
      , green = Player Green 0 0 0 0 0 0 0 [] True ""
      , yellow = Player Yellow 0 0 0 0 0 0 0 [] True ""
      , black = Player Black 0 0 0 0 0 0 0 [] True ""
      , currentPlayerColor = Red
      }
    , Cmd.none
    )


stationCost : Int
stationCost =
    4


view : Model -> Html Msg
view model =
    div [ class baseClass, class "page" ]
        [ statsView model
        , getPlayerByColor model model.currentPlayerColor
            |> playerView model.longest
        ]


getCounterFromPlayer : Player -> Counter -> Int
getCounterFromPlayer player counter =
    case counter of
        Station ->
            player.stations

        One ->
            player.ones

        Two ->
            player.twos

        Three ->
            player.threes

        Four ->
            player.fours

        Six ->
            player.sixes

        Eight ->
            player.eights


counterToInt : Counter -> Int
counterToInt counter =
    case counter of
        Station ->
            0

        One ->
            1

        Two ->
            2

        Three ->
            3

        Four ->
            4

        Six ->
            6

        Eight ->
            8


getCarsLeft : Player -> Int
getCarsLeft player =
    let
        ones =
            player.ones * counterToInt One

        twos =
            player.twos * counterToInt Two

        threes =
            player.threes * counterToInt Three

        fours =
            player.fours * counterToInt Four

        sixes =
            player.sixes * counterToInt Six

        eights =
            player.eights * counterToInt Eight
    in
    45 - ones - twos - threes - fours - sixes - eights


initialCarsCount : Int
initialCarsCount =
    3


getPoints : Longest -> Player -> Int
getPoints longest player =
    let
        initial =
            initialCarsCount * stationCost

        stations =
            player.stations * -stationCost

        ones =
            player.ones * 1

        twos =
            player.twos * 2

        threes =
            player.threes * 4

        fours =
            player.fours * 7

        sixes =
            player.sixes * 15

        eights =
            player.eights * 21

        routes =
            List.foldl
                (\route acc ->
                    if route.completed then
                        acc + route.points

                    else
                        acc - route.points
                )
                0
                player.routes

        longestPoints =
            case longest of
                Color color ->
                    if color == player.color then
                        10

                    else
                        0

                Unknown ->
                    0
    in
    initial + stations + ones + twos + threes + fours + sixes + eights + routes + longestPoints


statsView : Model -> Html Msg
statsView { red, blue, green, yellow, black, currentPlayerColor, longest } =
    fieldset [ c "playerStats" ]
        (legend [ class "visuallyHidden" ] [ text "Player Stats" ]
            :: ([ red, blue, green, yellow, black ]
                    |> List.map
                        (\player ->
                            playerStatView
                                longest
                                currentPlayerColor
                                player
                        )
               )
        )


playerStatView : Longest -> Color -> Player -> Html Msg
playerStatView longest currentPlayerColor player =
    let
        colorString =
            colorToString player.color

        inputId =
            "playerStatRadio" ++ colorString
    in
    div [ c "playerStat", c ("playerStat__" ++ colorString) ]
        [ div [ c "carsLeft" ]
            [ text ("Cars: " ++ String.fromInt (getCarsLeft player)) ]
        , div [ c "playerStatPoints" ]
            [ text ("Points: " ++ String.fromInt (getPoints longest player)) ]
        , input
            [ c "playerStatRadio"
            , c ("playerStatRadio__" ++ colorString)
            , type_ "radio"
            , id inputId
            , name "playerStat"
            , checked (currentPlayerColor == player.color)
            , onClick (SelectPlayer player.color)
            ]
            []
        , label [ c "playerStatLabel", for inputId ] []
        ]


counterView : Color -> Counter -> Int -> Html Msg
counterView color counter value =
    let
        decrementDisabled =
            value <= 0
    in
    div [ c "counter" ]
        [ div [ c "counterText" ] [ text (conunterToStringCount counter) ]
        , button
            [ c "counterButton"
            , ifAttr decrementDisabled (c "counterButton__disabled")
            , disabled decrementDisabled
            , onClick (Decrement color counter)
            ]
            [ text "-" ]
        , button [ c "counterButton", onClick (Increment color counter) ]
            [ text "+" ]
        , div [ c "counterValue" ] [ text (String.fromInt value) ]
        ]


playerView : Longest -> Player -> Html Msg
playerView longest { color, stations, ones, twos, threes, fours, sixes, eights, routes, completed, routeInput } =
    let
        counterWithColor counter value =
            counterView color counter value
    in
    div [ c "player", c ("player__" ++ colorToString color) ]
        [ counterWithColor One ones
        , counterWithColor Two twos
        , counterWithColor Three threes
        , counterWithColor Four fours
        , counterWithColor Six sixes
        , counterWithColor Eight eights
        , counterWithColor Station stations
        , longestView color longest
        , routeInputView color completed routeInput
        , routesView color routes
        ]


routeInputView : Color -> Bool -> String -> Html Msg
routeInputView color completed points =
    let
        checkboxId =
            "routeCheckbox" ++ colorToString color

        inputId =
            "routeInput" ++ colorToString color

        isAddButtonDisabled =
            (String.toInt points
                |> Maybe.andThen
                    (\p ->
                        if p < 0 then
                            Nothing

                        else
                            Just p
                    )
            )
                == Nothing
    in
    div [ c "routeInputsContainer" ]
        [ form
            [ c "routeInputContainer"
            , onSubmit
                (case String.toInt points of
                    Nothing ->
                        NoOp

                    Just pointsNumber ->
                        AddRoute color { completed = completed, points = pointsNumber }
                )
            ]
            [ label [ class "visuallyHidden", for inputId ] [ text "Points" ]
            , input
                [ c "routeInput"
                , type_ "text"
                , inputmode "numeric"
                , pattern "\\d*"
                , id inputId
                , value points
                , onInput (SetRouteInput color)
                , placeholder "Route"
                ]
                []
            , button
                [ c "routeAddButton"
                , ifAttr isAddButtonDisabled (c "routeAddButton__disabled")
                , ifAttr isAddButtonDisabled (disabled True)
                ]
                [ text "Add" ]
            ]
        , div [ c "checkboxContainer" ]
            [ label [ c "checkboxLabel", for checkboxId ] [ text "Completed" ]
            , input
                [ c "checkbox"
                , c ("checkbox__" ++ colorToString color)
                , type_ "checkbox"
                , id checkboxId
                , checked completed
                , onCheck (ToggleCompleted color)
                ]
                []
            ]
        ]


routesView : Color -> List Route -> Html Msg
routesView color routes =
    div [ c "routes" ]
        (List.indexedMap (routeView color) routes)


routeView : Color -> Int -> Route -> Html Msg
routeView color index { points, completed } =
    div [ c "route" ]
        [ div [ c "routePoints" ]
            [ text
                ((if completed then
                    ""

                  else
                    "-"
                 )
                    ++ String.fromInt points
                )
            ]
        , div [ c "routeCompleted" ]
            [ text
                (if completed then
                    "Completed"

                 else
                    "Not Completed"
                )
            ]
        , button
            [ c "routeRemoveButton"
            , onClick (RemoveRoute color index)
            ]
            [ text "Remove" ]
        ]


longestView : Color -> Longest -> Html Msg
longestView color longest =
    let
        colorString =
            colorToString color

        longestId =
            "longest" ++ colorString
    in
    div [ c "checkboxContainer" ]
        [ label [ c "checkboxLabel", for longestId ] [ text "Longest" ]
        , input
            [ c "checkbox"
            , c ("checkbox__" ++ colorString)
            , id longestId
            , type_ "checkbox"
            , name "longest"
            , onCheck (SetLongest color)
            , checked
                (case longest of
                    Unknown ->
                        False

                    Color col ->
                        col == color
                )
            ]
            []
        ]



-- update


type Msg
    = Increment Color Counter
    | Decrement Color Counter
    | SelectPlayer Color
    | SetLongest Color Bool
    | ToggleCompleted Color Bool
    | SetRouteInput Color String
    | AddRoute Color Route
    | RemoveRoute Color Int
    | NoOp


updateByColorWithResult : Model -> Color -> (Player -> Result CounterError Player) -> Result CounterError Model
updateByColorWithResult model color up =
    getPlayerByColor model color
        |> up
        |> Result.map
            (\player ->
                updateByColor model color (\_ -> player)
            )


updateByColor : Model -> Color -> (Player -> Player) -> Model
updateByColor model color up =
    let
        updatedPlayer =
            getPlayerByColor model color
                |> up
    in
    case color of
        Red ->
            { model | red = updatedPlayer }

        Blue ->
            { model | blue = updatedPlayer }

        Green ->
            { model | green = updatedPlayer }

        Yellow ->
            { model | yellow = updatedPlayer }

        Black ->
            { model | black = updatedPlayer }


type CounterError
    = CounterError


updateCounter : Counter -> Player -> (( Player, Int ) -> Result CounterError Int) -> Result CounterError Player
updateCounter counter player up =
    let
        commonUpdate fieldUpdate =
            up ( player, getCounterFromPlayer player counter )
                |> Result.map fieldUpdate
    in
    case counter of
        Station ->
            commonUpdate (\value -> { player | stations = value })

        One ->
            commonUpdate (\count -> { player | ones = count })

        Two ->
            commonUpdate (\count -> { player | twos = count })

        Three ->
            commonUpdate (\count -> { player | threes = count })

        Four ->
            commonUpdate (\count -> { player | fours = count })

        Six ->
            commonUpdate (\count -> { player | sixes = count })

        Eight ->
            commonUpdate (\count -> { player | eights = count })


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment color counter ->
            (\( player, value ) ->
                case counter of
                    Station ->
                        if player.stations >= initialCarsCount then
                            Err CounterError

                        else
                            Ok (value + 1)

                    _ ->
                        if counterToInt counter > getCarsLeft player then
                            Err CounterError

                        else
                            Ok (value + 1)
            )
                |> (\up ->
                        updateByColorWithResult model
                            color
                            (\player ->
                                updateCounter counter player up
                            )
                            |> Result.withDefault model
                            |> (\m -> ( m, Cmd.none ))
                   )

        Decrement color counter ->
            (\( _, value ) ->
                if value <= 0 then
                    Err CounterError

                else
                    Ok (value - 1)
            )
                |> (\up ->
                        updateByColorWithResult model
                            color
                            (\player ->
                                updateCounter counter player up
                            )
                            |> Result.withDefault model
                            |> (\m -> ( m, Cmd.none ))
                   )

        SelectPlayer color ->
            ( { model | currentPlayerColor = color }, Cmd.none )

        SetLongest color isLongest ->
            if isLongest then
                ( { model | longest = Color color }, Cmd.none )

            else
                ( { model | longest = Unknown }, Cmd.none )

        ToggleCompleted color completed ->
            ( updateByColor
                model
                color
                (\player -> { player | completed = completed })
            , Cmd.none
            )

        SetRouteInput color points ->
            ( updateByColor
                model
                color
                (\player -> { player | routeInput = points })
            , Cmd.none
            )

        AddRoute color route ->
            ( updateByColor
                model
                color
                (\player ->
                    { player
                        | routes = route :: player.routes
                        , routeInput = ""
                    }
                )
            , Cmd.none
            )

        RemoveRoute color index ->
            ( updateByColor
                model
                color
                (\player ->
                    { player
                        | routes =
                            player.routes
                                |> List.indexedMap (\i -> \route -> ( i, route ))
                                |> List.filterMap
                                    (\( i, route ) ->
                                        if i == index then
                                            Nothing

                                        else
                                            Just route
                                    )
                    }
                )
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

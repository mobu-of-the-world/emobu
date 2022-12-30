module Session exposing (ForEachUnit, IntervalUnit(..), newIntervalOptions, readableElapsed, updateIntervalSeconds)

import Time exposing (Posix, millisToPosix, toHour, toMinute, toSecond, utc)


type alias ForEachUnit =
    { hour : Int
    , min : Int
    , sec : Int
    }


type IntervalUnit
    = Hour
    | Min
    | Sec


readableElapsed : Int -> String
readableElapsed seconds =
    let
        time : Posix
        time =
            millisToPosix (seconds * 1000)
    in
    String.padLeft 2 '0' (String.fromInt (toHour utc time))
        ++ ":"
        ++ String.padLeft 2 '0' (String.fromInt (toMinute utc time))
        ++ ":"
        ++ String.padLeft 2 '0' (String.fromInt (toSecond utc time))


forEachUnit : Int -> ForEachUnit
forEachUnit totalSeconds =
    let
        sec =
            remainderBy 60 totalSeconds

        hour =
            totalSeconds // (60 * 60)

        min =
            (totalSeconds // 60) - (hour * 60)
    in
    ForEachUnit hour min sec


formatElapsedUnit : Int -> String
formatElapsedUnit val =
    String.padLeft 2 '0' (String.fromInt val)


radixToSeconds : IntervalUnit -> Int
radixToSeconds unit =
    case unit of
        Hour ->
            60 * 60

        Min ->
            60

        Sec ->
            1


updateIntervalSeconds : Int -> IntervalUnit -> Int -> Int
updateIntervalSeconds new unit current =
    let
        currentInterval =
            forEachUnit current

        currentInUnit =
            case unit of
                Hour ->
                    currentInterval.hour

                Min ->
                    currentInterval.min

                Sec ->
                    currentInterval.sec

        diff =
            new - currentInUnit

        radix =
            radixToSeconds unit
    in
    current + (diff * radix)


newIntervalOptions : Int -> ( List ( String, Bool ), List ( String, Bool ), List ( String, Bool ) )
newIntervalOptions current =
    let
        currentForEachUnit =
            current |> forEachUnit
    in
    ( List.range
        0
        2
        |> List.map
            (\int -> ( formatElapsedUnit int, currentForEachUnit.hour == int ))
    , List.range
        0
        59
        |> List.filter (\item -> (item |> remainderBy 5) == 0)
        |> List.map
            (\int -> ( formatElapsedUnit int, currentForEachUnit.min == int ))
    , List.range
        0
        59
        |> List.filter (\item -> (item |> remainderBy 5) == 0)
        |> List.map
            (\int -> ( formatElapsedUnit int, currentForEachUnit.sec == int ))
    )

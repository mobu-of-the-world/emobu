module Duration exposing (Duration, elapsedSecondsFromDurations, updateLatest)

import Time exposing (Posix, posixToMillis)


type alias Duration =
    ( Posix, Posix )


toMillis : Duration -> Int
toMillis ( begin, end ) =
    posixToMillis end - posixToMillis begin


elapsedSecondsFromDurations : List Duration -> Int
elapsedSecondsFromDurations durations =
    (durations
        |> List.map toMillis
        |> List.foldl (+) 0
    )
        // 1000


updateLatest : Posix -> List Duration -> List Duration
updateLatest moment durations =
    let
        ( ( begin, _ ), befores ) =
            case durations of
                latest :: rest ->
                    ( latest, rest )

                [] ->
                    ( ( moment, moment ), [] )
    in
    ( begin, moment ) :: befores

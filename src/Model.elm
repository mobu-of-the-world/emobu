module Model exposing (DecodedModel, InputtedInterval, Model, User, decoder, defaultValues, encode, intervalsToSeconds)

import Json.Decode
import Json.Encode


type alias User =
    { username : String
    , avatarUrl : String
    }



-- type IntervalUnit
--     = Min
--     | Sec


type alias InputtedInterval =
    { seconds : String
    , minutes : String
    , hours : String
    }


type alias Model =
    { inputtedUsername : String
    , users : List User
    , elapsedSeconds : Int
    , intervalSeconds : Int
    , inputtedInterval : InputtedInterval
    , mobbing : Bool
    , enabledSound : Bool
    , commitRef : String

    -- , intervalUnit : IntervalUnit
    }


type alias DecodedModel =
    { users : List User, commitRef : Maybe String, enabledSound : Maybe Bool }


defaultIntervalSeconds : Int
defaultIntervalSeconds =
    30 * 60


secondsToIntervals : Int -> InputtedInterval
secondsToIntervals totalSeconds =
    let
        format : Int -> String
        format val =
            String.padLeft 2 '0' (String.fromInt val)

        sec =
            remainderBy 60 totalSeconds

        hour =
            totalSeconds // (60 * 60)

        min =
            (totalSeconds // 60) - (hour * 60)
    in
    InputtedInterval (format sec) (format min) (format hour)


intervalsToSeconds : InputtedInterval -> Maybe Int
intervalsToSeconds intervals =
    let
        maybeHour =
            String.toInt intervals.hours

        maybeMinutes =
            String.toInt intervals.minutes

        maybeSeconds =
            String.toInt intervals.seconds
    in
    case ( maybeHour, maybeMinutes, maybeSeconds ) of
        ( Just hour, Just min, Just sec ) ->
            Just ((hour * (60 * 60)) + (min * 60) + sec)

        _ ->
            Nothing



-- (Maybe.withDefault 0 (String.toInt intervals.hours) * (60 * 60)) + (Maybe.withDefault 0 (String.toInt intervals.minutes) * 60) + Maybe.withDefault 0 (String.toInt intervals.seconds)


defaultValues : Model
defaultValues =
    { users = []
    , inputtedUsername = ""
    , elapsedSeconds = 0
    , intervalSeconds = defaultIntervalSeconds
    , inputtedInterval = secondsToIntervals defaultIntervalSeconds
    , mobbing = False
    , enabledSound = True
    , commitRef = "unknown ref"

    -- , intervalUnit = Min
    }


userEncoder : User -> Json.Encode.Value
userEncoder user =
    Json.Encode.object [ ( "username", Json.Encode.string user.username ), ( "avatarUrl", Json.Encode.string user.avatarUrl ) ]


encode : Model -> Json.Encode.Value
encode model =
    Json.Encode.object
        [ ( "users", Json.Encode.list userEncoder model.users )
        , ( "enabledSound", Json.Encode.bool model.enabledSound )
        ]


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map2 User
        (Json.Decode.field "username" Json.Decode.string)
        (Json.Decode.field "avatarUrl" Json.Decode.string)


decoder : Json.Decode.Decoder DecodedModel
decoder =
    Json.Decode.map3 DecodedModel
        (Json.Decode.field "users" (Json.Decode.list userDecoder))
        (Json.Decode.maybe (Json.Decode.field "commitRef" Json.Decode.string))
        (Json.Decode.maybe (Json.Decode.field "enabledSound" Json.Decode.bool))

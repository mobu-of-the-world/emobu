module Model exposing (Model, PersistedModel, User, decoder, defaultValues, encode)

import Json.Decode
import Json.Encode


type alias User =
    { username : String
    , avatarUrl : String
    }


type alias Model =
    { inputtedUsername : String
    , users : List User
    , elapsedSeconds : Int
    , intervalSeconds : Int
    , mobbing : Bool
    , enabledSound : Bool
    , gitRef : String
    }


type alias PersistedModel =
    -- TODO: Consider to versioning config structure with `andThen`
    { users : List User, enabledSound : Bool, intervalSeconds : Int }


defaultIntervalSeconds : Int
defaultIntervalSeconds =
    30 * 60


defaultValues : Model
defaultValues =
    { users = []
    , inputtedUsername = ""
    , elapsedSeconds = 0
    , intervalSeconds = defaultIntervalSeconds
    , mobbing = False
    , enabledSound = True
    , gitRef = "unknown ref"
    }


userEncoder : User -> Json.Encode.Value
userEncoder user =
    Json.Encode.object [ ( "username", Json.Encode.string user.username ), ( "avatarUrl", Json.Encode.string user.avatarUrl ) ]


encode : Model -> Json.Encode.Value
encode model =
    Json.Encode.object
        [ ( "users", Json.Encode.list userEncoder model.users )
        , ( "enabledSound", Json.Encode.bool model.enabledSound )
        , ( "intervalSeconds", Json.Encode.int model.intervalSeconds )
        ]


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map2 User
        (Json.Decode.field "username" Json.Decode.string)
        (Json.Decode.field "avatarUrl" Json.Decode.string)


decoder : Json.Decode.Decoder PersistedModel
decoder =
    Json.Decode.map3 PersistedModel
        (Json.Decode.field "users" (Json.Decode.list userDecoder))
        (Json.Decode.field "enabledSound" Json.Decode.bool)
        (Json.Decode.field "intervalSeconds" Json.Decode.int)

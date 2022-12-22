module Model exposing (DecodedModel, Model, User, decoder, defaultValues, encode)

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
    , inputtedIntervalMinutes : String
    , mobbing : Bool
    , debugMode : Bool
    , commitRef : String
    }


type alias DecodedModel =
    { users : List User, commitRef : String }


defaultIntervalMinutes : Int
defaultIntervalMinutes =
    30


defaultValues : Model
defaultValues =
    { users = []
    , inputtedUsername = ""
    , elapsedSeconds = 0
    , intervalSeconds = defaultIntervalMinutes * 60
    , inputtedIntervalMinutes = String.fromInt defaultIntervalMinutes
    , mobbing = False
    , debugMode = False
    , commitRef = ""
    }


userEncoder : User -> Json.Encode.Value
userEncoder user =
    Json.Encode.object [ ( "username", Json.Encode.string user.username ), ( "avatarUrl", Json.Encode.string user.avatarUrl ) ]


encode : Model -> Json.Encode.Value
encode model =
    Json.Encode.object
        [ ( "users", Json.Encode.list userEncoder model.users ) ]


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map2 User
        (Json.Decode.field "username" Json.Decode.string)
        (Json.Decode.field "avatarUrl" Json.Decode.string)


decoder : Json.Decode.Decoder DecodedModel
decoder =
    Json.Decode.map2 DecodedModel
        (Json.Decode.field "users" (Json.Decode.list userDecoder))
        (Json.Decode.field "commitRef" Json.Decode.string)

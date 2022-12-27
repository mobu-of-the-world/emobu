module Model exposing (Model, PersistedModel, PersistedUser, User, decoder, defaultPersistedValues, defaultValues, encode)

import Json.Decode
import Json.Encode


type alias User =
    { username : String
    , avatarUrl : String
    }


type alias PersistedUser =
    -- Keep record style for easier extending even if actually one field exists
    { username : String }


type alias Model =
    { inputtedUsername : String
    , users : List User
    , elapsedSeconds : Int
    , intervalSeconds : Int
    , mobbing : Bool
    , enabledSound : Bool
    , enabledNotification : Bool
    , gitRef : String
    }


type alias PersistedModel =
    -- TODO: Consider to versioning config structure with `andThen`
    -- enabledNotification Ccn't be persisted because users can change the permission without local storage
    { users : List PersistedUser, enabledSound : Bool, intervalSeconds : Int }


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
    , enabledNotification = False
    , gitRef = "unknown ref"
    }


defaultPersistedValues : PersistedModel
defaultPersistedValues =
    { users = defaultValues.users |> List.map (\user -> { username = user.username })
    , enabledSound = defaultValues.enabledSound
    , intervalSeconds = defaultValues.intervalSeconds
    }


userEncoder : User -> Json.Encode.Value
userEncoder user =
    Json.Encode.object [ ( "username", Json.Encode.string user.username ) ]


encode : Model -> Json.Encode.Value
encode model =
    Json.Encode.object
        [ ( "users", Json.Encode.list userEncoder model.users )
        , ( "enabledSound", Json.Encode.bool model.enabledSound )
        , ( "intervalSeconds", Json.Encode.int model.intervalSeconds )
        ]


userDecoder : Json.Decode.Decoder PersistedUser
userDecoder =
    Json.Decode.map PersistedUser
        (Json.Decode.field "username" Json.Decode.string)


decoder : Json.Decode.Decoder PersistedModel
decoder =
    Json.Decode.map3 PersistedModel
        (Json.Decode.field "users" (Json.Decode.list userDecoder))
        (Json.Decode.field "enabledSound" Json.Decode.bool)
        (Json.Decode.field "intervalSeconds" Json.Decode.int)

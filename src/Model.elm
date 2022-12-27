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
    -- enabledNotification does not mean to be notified, because users can change the permission without app layer. This mean to try.
    { users : List PersistedUser, enabledSound : Bool, enabledNotification : Bool, intervalSeconds : Int }


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
    , enabledNotification = defaultValues.enabledNotification
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
        , ( "enabledNotification", Json.Encode.bool model.enabledNotification )
        , ( "intervalSeconds", Json.Encode.int model.intervalSeconds )
        ]


userDecoder : Json.Decode.Decoder PersistedUser
userDecoder =
    Json.Decode.map PersistedUser
        (Json.Decode.field "username" Json.Decode.string)


decoder : Json.Decode.Decoder PersistedModel
decoder =
    Json.Decode.map4 PersistedModel
        (Json.Decode.field "users" (Json.Decode.list userDecoder))
        (Json.Decode.field "enabledSound" Json.Decode.bool)
        (Json.Decode.field "enabledNotification" Json.Decode.bool)
        (Json.Decode.field "intervalSeconds" Json.Decode.int)

module ModelTests exposing (decoderTests, encoderTests)

import Expect
import Json.Decode
import Json.Encode
import Model exposing (PersistedModel, decoder, defaultValues, encode)
import Test exposing (Test, test)


decoderTests : Test
decoderTests =
    test "Decode a json to model" <|
        \() ->
            let
                input : String
                input =
                    """
                      {
                        "users":[
                            {"username":"pankona"},
                            {"username":"kachick"},
                            {"username":"does not exist"}
                        ],
                        "enabledSound":true,"intervalSeconds":1850
                      }
                    """

                decodedOutput : Result Json.Decode.Error PersistedModel
                decodedOutput =
                    Json.Decode.decodeString
                        decoder
                        input
            in
            Expect.equal decodedOutput
                (Ok
                    { users =
                        [ { username = "pankona" }
                        , { username = "kachick" }
                        , { username = "does not exist" }
                        ]
                    , enabledSound = True
                    , intervalSeconds = 1850
                    }
                )


encoderTests : Test
encoderTests =
    test "Encode a model to json" <|
        \() ->
            let
                model : Model.Model
                model =
                    { defaultValues
                        | users =
                            [ { username = "pankona", avatarUrl = "https://github.com/pankona.png" }
                            , { username = "kachick", avatarUrl = "https://github.com/kachick.png" }
                            , { username = "does not exist", avatarUrl = "https://raw.githubusercontent.com/mobu-of-the-world/mobu/main/public/images/default-profile-icon.png" }
                            ]
                        , gitRef = "27d1d7c"
                        , enabledSound = True
                        , intervalSeconds = 42
                    }

                encoodedOutput : String
                encoodedOutput =
                    Json.Encode.encode 4 (encode model)

                decodedAgain : Result Json.Decode.Error PersistedModel
                decodedAgain =
                    Json.Decode.decodeString decoder encoodedOutput
            in
            Expect.equal decodedAgain
                (Ok
                    { users =
                        [ { username = "pankona" }
                        , { username = "kachick" }
                        , { username = "does not exist" }
                        ]
                    , enabledSound = True
                    , intervalSeconds = 42
                    }
                )

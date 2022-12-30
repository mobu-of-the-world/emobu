module MainTests exposing (decoderTests, encoderTests)

import Expect
import Json.Decode
import Json.Encode
import Main exposing (PersistedModel, defaultModel, modelDecoder, modelEncoder)
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
                        "enabledSound":true,
                        "enabledNotification":true,
                        "intervalSeconds":1850
                      }
                    """

                decodedOutput : Result Json.Decode.Error PersistedModel
                decodedOutput =
                    Json.Decode.decodeString
                        modelDecoder
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
                    , enabledNotification = True
                    , intervalSeconds = 1850
                    }
                )


encoderTests : Test
encoderTests =
    test "Encode a model to json" <|
        \() ->
            let
                model : Main.Model
                model =
                    { defaultModel
                        | users =
                            [ { username = "pankona", avatarUrl = "https://github.com/pankona.png" }
                            , { username = "kachick", avatarUrl = "https://github.com/kachick.png" }
                            , { username = "does not exist", avatarUrl = "/images/default-profile-icon.png" }
                            ]
                        , gitRef = "27d1d7c"
                        , enabledSound = True
                        , enabledNotification = False
                        , intervalSeconds = 42
                    }

                encoodedOutput : String
                encoodedOutput =
                    Json.Encode.encode 4 (modelEncoder model)

                decodedAgain : Result Json.Decode.Error PersistedModel
                decodedAgain =
                    Json.Decode.decodeString modelDecoder encoodedOutput
            in
            Expect.equal decodedAgain
                (Ok
                    { users =
                        [ { username = "pankona" }
                        , { username = "kachick" }
                        , { username = "does not exist" }
                        ]
                    , enabledSound = True
                    , enabledNotification = False
                    , intervalSeconds = 42
                    }
                )

module ModelTests exposing (decoderTests, encoderTests)

import Expect
import Json.Decode
import Json.Encode
import Model exposing (decoder, defaultValues, encode)
import Test exposing (Test, test)


decoderTests : Test
decoderTests =
    test "Decode a json to model" <|
        \() ->
            let
                input : String
                input =
                    """
                      {"users":[{"username":"pankona","avatarUrl":"https://github.com/pankona.png"},{"username":"kachick","avatarUrl":"https://github.com/kachick.png"},{"username":"does not exist","avatarUrl":"https://raw.githubusercontent.com/mobu-of-the-world/mobu/main/public/images/default-profile-icon.png"}]}
                    """

                decodedOutput : Result Json.Decode.Error { users : List Model.User }
                decodedOutput =
                    Json.Decode.decodeString
                        decoder
                        input
            in
            Expect.equal decodedOutput
                (Ok
                    { users =
                        [ { username = "pankona", avatarUrl = "https://github.com/pankona.png" }
                        , { username = "kachick", avatarUrl = "https://github.com/kachick.png" }
                        , { username = "does not exist", avatarUrl = "https://raw.githubusercontent.com/mobu-of-the-world/mobu/main/public/images/default-profile-icon.png" }
                        ]
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
                    }

                encoodedOutput : String
                encoodedOutput =
                    Json.Encode.encode 4 (encode model)

                decodedAgain : Result Json.Decode.Error { users : List Model.User }
                decodedAgain =
                    Json.Decode.decodeString decoder encoodedOutput
            in
            Expect.equal decodedAgain
                (Ok
                    { users =
                        [ { username = "pankona", avatarUrl = "https://github.com/pankona.png" }
                        , { username = "kachick", avatarUrl = "https://github.com/kachick.png" }
                        , { username = "does not exist", avatarUrl = "https://raw.githubusercontent.com/mobu-of-the-world/mobu/main/public/images/default-profile-icon.png" }
                        ]
                    }
                )

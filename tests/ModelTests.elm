module ModelTests exposing (decoderTests, encoderTests)

import Expect
import Json.Decode
import Json.Encode
import Model exposing (DecodedModel, decoder, defaultValues, encode)
import Test exposing (Test, test)


decoderTests : Test
decoderTests =
    test "Decode a json to model" <|
        \() ->
            let
                input : String
                input =
                    """
                      {"users":[{"username":"pankona","avatarUrl":"https://github.com/pankona.png"},{"username":"kachick","avatarUrl":"https://github.com/kachick.png"},{"username":"does not exist","avatarUrl":"https://raw.githubusercontent.com/mobu-of-the-world/mobu/main/public/images/default-profile-icon.png"}],"commitRef":"27d1d7c","enabledSound":true}
                    """

                decodedOutput : Result Json.Decode.Error DecodedModel
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
                    , commitRef = Just "27d1d7c"
                    , enabledSound = Just True
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
                        , commitRef = "27d1d7c"
                        , enabledSound = True
                    }

                encoodedOutput : String
                encoodedOutput =
                    Json.Encode.encode 4 (encode model)

                decodedAgain : Result Json.Decode.Error DecodedModel
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
                    , commitRef = Nothing
                    , enabledSound = Just True
                    }
                )

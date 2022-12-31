module MainTests exposing (decoderTests, encoderTests, moveUserTests)

import Expect
import Json.Decode
import Json.Encode
import Main exposing (PersistedModel, User, defaultModel, modelDecoder, modelEncoder, moveUser)
import Test exposing (Test, describe, test)


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


moveUserTests : Test
moveUserTests =
    let
        user1 =
            User "1" "url1"

        user2 =
            User "2" "url2"

        user3 =
            User "3" "url3"

        user4 =
            User "4" "url4"
    in
    describe "moveUser"
        [ test "head to tail" <|
            \() ->
                [ user1, user2, user3 ]
                    |> moveUser user1 user3
                    |> Expect.equal [ user2, user3, user1 ]
        , test "middle to tail" <|
            \() ->
                [ user1, user2, user3 ]
                    |> moveUser user2 user3
                    |> Expect.equal [ user1, user3, user2 ]
        , test "middle to head" <|
            \() ->
                [ user1, user2, user3 ]
                    |> moveUser user2 user1
                    |> Expect.equal [ user2, user1, user3 ]
        , test "tail to head" <|
            \() ->
                [ user1, user2, user3 ]
                    |> moveUser user3 user1
                    |> Expect.equal [ user3, user1, user2 ]
        , test "head to middle" <|
            \() ->
                [ user1, user2, user3 ]
                    |> moveUser user1 user2
                    |> Expect.equal [ user2, user1, user3 ]
        , test "tail to middle" <|
            \() ->
                [ user1, user2, user3 ]
                    |> moveUser user3 user2
                    |> Expect.equal [ user1, user3, user2 ]
        , test "head to head" <|
            \() ->
                [ user1, user2, user3 ]
                    |> moveUser user1 user1
                    |> Expect.equal [ user1, user2, user3 ]
        , test "middle to middle" <|
            \() ->
                [ user1, user2, user3 ]
                    |> moveUser user2 user2
                    |> Expect.equal [ user1, user2, user3 ]
        , test "tail to tail" <|
            \() ->
                [ user1, user2, user3 ]
                    |> moveUser user3 user3
                    |> Expect.equal [ user1, user2, user3 ]
        , test "single" <|
            \() ->
                [ user1 ]
                    |> moveUser user1 user1
                    |> Expect.equal [ user1 ]
        , test "missing" <|
            \() ->
                [ user1, user2 ]
                    |> moveUser user1 user3
                    |> Expect.equal [ user1, user2 ]
        , test "empty" <|
            \() ->
                []
                    |> moveUser user1 user1
                    |> Expect.equal []
        , test "middle to tail on more elements" <|
            \() ->
                [ user1, user2, user3, user4 ]
                    |> moveUser user2 user4
                    |> Expect.equal [ user1, user3, user4, user2 ]
        , test "middle to head on more elements" <|
            \() ->
                [ user1, user2, user3, user4 ]
                    |> moveUser user3 user1
                    |> Expect.equal [ user3, user1, user2, user4 ]
        ]

module MainTests exposing (durationsToElapsedSecondsTests, rotateTests)

import Expect
import Main exposing (durationsToElapsedSeconds, rotate)
import Test exposing (Test, describe, test)
import Time exposing (millisToPosix)


rotateTests : Test
rotateTests =
    describe "Rotate"
        [ test "rotates multiple items" <|
            \() ->
                [ 1, 2, 3 ]
                    |> rotate
                    |> Expect.equal [ 2, 3, 1 ]
        , test "rotates 2 items" <|
            \() ->
                [ 1, 2 ]
                    |> rotate
                    |> Expect.equal [ 2, 1 ]
        , test "does not change 1 item list" <|
            \() ->
                [ 1 ]
                    |> rotate
                    |> Expect.equal [ 1 ]
        , test "does not change empty list" <|
            \() ->
                []
                    |> rotate
                    |> Expect.equal []
        ]


durationsToElapsedSecondsTests : Test
durationsToElapsedSecondsTests =
    describe "durationsToElapsedSeconds"
        [ test "truncates msec" <|
            \() ->
                [ ( millisToPosix 1672399207825, millisToPosix 1672399215616 ) ]
                    |> durationsToElapsedSeconds
                    |> Expect.equal 7
        , test "truncates msec after sum" <|
            \() ->
                [ ( millisToPosix 1672399502101, millisToPosix 1672399554056 ), ( millisToPosix 1672399207825, millisToPosix 1672399215616 ) ]
                    |> durationsToElapsedSeconds
                    |> Expect.equal 59
        , test "returns 0 for empty" <|
            \() ->
                []
                    |> durationsToElapsedSeconds
                    |> Expect.equal 0
        ]

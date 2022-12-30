module DurationTests exposing (elapsedSecondsFromDurationsTests)

import Duration exposing (elapsedSecondsFromDurations)
import Expect
import Test exposing (Test, describe, test)
import Time exposing (millisToPosix)


elapsedSecondsFromDurationsTests : Test
elapsedSecondsFromDurationsTests =
    describe "elapsedSecondsFromDurations"
        [ test "truncates msec" <|
            \() ->
                [ ( millisToPosix 1672399207825, millisToPosix 1672399215616 ) ]
                    |> elapsedSecondsFromDurations
                    |> Expect.equal 7
        , test "truncates msec after sum" <|
            \() ->
                [ ( millisToPosix 1672399502101, millisToPosix 1672399554056 ), ( millisToPosix 1672399207825, millisToPosix 1672399215616 ) ]
                    |> elapsedSecondsFromDurations
                    |> Expect.equal 59
        , test "returns 0 for empty" <|
            \() ->
                []
                    |> elapsedSecondsFromDurations
                    |> Expect.equal 0
        ]

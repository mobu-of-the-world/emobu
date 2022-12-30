module MobSessionTests exposing (rotateTests)

import Expect
import MobSession exposing (rotate)
import Test exposing (Test, describe, test)


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

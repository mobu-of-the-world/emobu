module MainTests exposing (rotateTests)

import Expect
import Main exposing (rotate)
import Test exposing (Test, describe, test)


rotateTests : Test
rotateTests =
    describe "Rotate"
        [ test "rotates multiple items" <|
            \() ->
                [ 1, 2, 3 ]
                    |> rotate
                    |> Expect.equal [ 2, 3, 1 ]
        , test "does not change empty list" <|
            \() ->
                []
                    |> rotate
                    |> Expect.equal []
        ]

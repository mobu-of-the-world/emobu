module MainTests exposing (rotateTests)

import Expect
import Main exposing (rotate)
import Test exposing (Test, test)


rotateTests : Test
rotateTests =
    test "Rotate a list" <|
        \() ->
            [ 1, 2, 3 ]
                |> rotate
                |> Expect.equal [ 2, 3, 1 ]

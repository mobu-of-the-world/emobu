module Main exposing (main)

import Browser
import Json.Decode
import Json.Encode
import Messages exposing (Msg(..))
import Model exposing (Model, decoder, defaultValues)
import Page.App exposing (view)
import Time exposing (every)
import Update exposing (updateWithStorage)


main : Program Json.Encode.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = subscriptions
        }


init : Json.Encode.Value -> ( Model, Cmd Msg )
init flags =
    ( case Json.Decode.decodeValue decoder flags of
        Ok decodedModel ->
            { defaultValues | users = decodedModel.users, commitRef = decodedModel.commitRef }

        Err _ ->
            defaultValues
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.mobbing then
        every 1000 Tick

    else
        Sub.none

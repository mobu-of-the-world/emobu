module Main exposing (main)

import App.Messages exposing (Msg(..))
import App.Model exposing (Model, decoder, defaultValues)
import App.Update exposing (updateWithStorage)
import App.View exposing (view)
import Browser
import Json.Decode
import Json.Encode
import Time exposing (every)


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

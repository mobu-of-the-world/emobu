port module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Json.Encode
import Random
import Random.List
import Task exposing (onError)


main : Program Json.Encode.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { inputtedUsername : String
    , usernames : List String
    }


init : Json.Encode.Value -> ( Model, Cmd Msg )
init flags =
    ( case Json.Decode.decodeValue decoder flags of
        Ok model ->
            model

        Err _ ->
            { inputtedUsername = "", usernames = [] }
    , Cmd.none
    )


type Msg
    = Input String
    | Add
    | Shuffle
    | GotNewUsernames (List String)
    | Delete String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input input ->
            ( { model | inputtedUsername = input }, Cmd.none )

        Add ->
            ( { model | inputtedUsername = "", usernames = String.trim model.inputtedUsername :: model.usernames }, Cmd.none )

        Shuffle ->
            ( model, getNewUsernames model )

        GotNewUsernames newUsernames ->
            ( { model | usernames = newUsernames }, Cmd.none )

        Delete username ->
            ( { model | usernames = List.filter (\element -> not (element == username)) model.usernames }, Cmd.none )


port setStorage : Json.Encode.Value -> Cmd msg


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg oldModel =
    let
        ( newModel, cmds ) =
            update msg oldModel
    in
    ( newModel
    , Cmd.batch [ setStorage (encode newModel), cmds ]
    )


encode : Model -> Json.Encode.Value
encode model =
    Json.Encode.object
        [ ( "usernames", Json.Encode.list Json.Encode.string model.usernames ), ( "inputtedUsername", Json.Encode.string model.inputtedUsername ) ]


decoder : Json.Decode.Decoder Model
decoder =
    Json.Decode.map2 Model
        (Json.Decode.field "inputtedUsername" Json.Decode.string)
        (Json.Decode.field "usernames" (Json.Decode.list Json.Decode.string))


view : Model -> Html Msg
view model =
    div []
        [ Html.form [ onSubmit Add ]
            [ input [ value model.inputtedUsername, onInput Input, placeholder "Username" ] []
            , button
                [ disabled (String.isEmpty (String.trim model.inputtedUsername) || List.member (String.trim model.inputtedUsername) model.usernames) ]
                [ text "Add" ]
            ]
        , button
            [ disabled (List.isEmpty model.usernames), onClick Shuffle ]
            [ text "Shuffle" ]
        , ul [] (List.map viewUsername model.usernames)
        ]


viewUsername : String -> Html Msg
viewUsername username =
    li []
        [ img [ src ("https://github.com/" ++ username ++ ".png"), style "width" "32px", style "border-radius" "50%" ] []
        , text username
        , button [ onClick (Delete username) ] [ text "Delete" ]
        ]


getNewUsernames : Model -> Cmd Msg
getNewUsernames model =
    Random.generate GotNewUsernames <| Random.List.shuffle model.usernames

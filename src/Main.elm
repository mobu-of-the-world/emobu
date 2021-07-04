module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random
import Random.List


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { inputtedUsername : String
    , usernames : List String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { inputtedUsername = "", usernames = [] }, Cmd.none )


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
    li [] [ text username, button [ onClick (Delete username) ] [ text "Delete" ] ]


getNewUsernames : Model -> Cmd Msg
getNewUsernames model =
    Random.generate GotNewUsernames <| Random.List.shuffle model.usernames

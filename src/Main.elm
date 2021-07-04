port module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Json.Encode
import List.Extra
import Random
import Random.List
import Task exposing (onError)
import Time


main : Program Json.Encode.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = subscriptions
        }


type alias Model =
    { inputtedUsername : String
    , usernames : List String
    , elapsedSeconds : Int
    , intervalSeconds : Int
    , inputtedIntervalMinutes : String
    , mobbing : Bool
    }


type alias DecodedModel =
    { usernames : List String }


defaultValues : Model
defaultValues =
    { usernames = [], inputtedUsername = "", elapsedSeconds = 0, intervalSeconds = 30 * 60, inputtedIntervalMinutes = "30", mobbing = False }


init : Json.Encode.Value -> ( Model, Cmd Msg )
init flags =
    ( case Json.Decode.decodeValue decoder flags of
        Ok decodedModel ->
            { defaultValues | usernames = decodedModel.usernames }

        Err _ ->
            defaultValues
    , Cmd.none
    )


type Msg
    = InputUsername String
    | AddUser
    | ShuffleUsers
    | GotNewUsernames (List String)
    | DeleteUser String
    | Tick Time.Posix
    | InputIntervalMinutes String
    | UpdateIntervalMinutes
    | ToggleMobbingState
    | ResetTimer


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputUsername input ->
            ( { model | inputtedUsername = input }, Cmd.none )

        InputIntervalMinutes input ->
            ( { model | inputtedIntervalMinutes = input }, Cmd.none )

        AddUser ->
            ( { model | inputtedUsername = "", usernames = String.trim model.inputtedUsername :: model.usernames }, Cmd.none )

        UpdateIntervalMinutes ->
            let
                newIntervalMinutesMaybe : Maybe Int
                newIntervalMinutesMaybe =
                    String.toInt model.inputtedIntervalMinutes

                newIntervalMinutes : Int
                newIntervalMinutes =
                    case newIntervalMinutesMaybe of
                        Nothing ->
                            30

                        Just minutes ->
                            minutes
            in
            ( { model | intervalSeconds = newIntervalMinutes * 60 }, Cmd.none )

        ShuffleUsers ->
            ( model, getNewUsernames model )

        GotNewUsernames newUsernames ->
            ( { model | usernames = newUsernames }, Cmd.none )

        DeleteUser username ->
            ( { model | usernames = List.filter (\element -> not (element == username)) model.usernames }, Cmd.none )

        ToggleMobbingState ->
            ( { model | mobbing = not model.mobbing }, Cmd.none )

        ResetTimer ->
            ( { model | mobbing = False, elapsedSeconds = 0 }, Cmd.none )

        Tick _ ->
            let
                newElapsedSeconds : Int
                newElapsedSeconds =
                    model.elapsedSeconds + 1

                timeOver : Bool
                timeOver =
                    newElapsedSeconds >= model.intervalSeconds

                newUsernames : List String
                newUsernames =
                    if timeOver then
                        List.Extra.swapAt 0 (List.length model.usernames - 1) model.usernames

                    else
                        model.usernames
            in
            ( { model
                | mobbing =
                    if timeOver then
                        False

                    else
                        model.mobbing
                , usernames = newUsernames
                , elapsedSeconds =
                    if timeOver then
                        0

                    else
                        newElapsedSeconds
              }
            , Cmd.none
            )


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
        [ ( "usernames", Json.Encode.list Json.Encode.string model.usernames ) ]


decoder : Json.Decode.Decoder DecodedModel
decoder =
    Json.Decode.map DecodedModel
        (Json.Decode.field "usernames" (Json.Decode.list Json.Decode.string))


view : Model -> Html Msg
view model =
    div []
        [ Html.form [ onSubmit AddUser ]
            [ input [ value model.inputtedUsername, onInput InputUsername, placeholder "Username" ] []
            , button
                [ disabled (String.isEmpty (String.trim model.inputtedUsername) || List.member (String.trim model.inputtedUsername) model.usernames) ]
                [ text "Add" ]
            ]
        , button
            [ disabled (List.length model.usernames < 2), onClick ShuffleUsers ]
            [ text "Shuffle" ]
        , ul [] (List.map viewUsername model.usernames)
        , br [] []
        , text ("Elapsed seconds: " ++ String.fromInt model.elapsedSeconds)
        , br [] []
        , text ("Elapsed minutes: " ++ String.fromInt (model.elapsedSeconds // 60))
        , br [] []
        , button
            [ disabled (List.length model.usernames < 2), onClick ToggleMobbingState ]
            [ text "Start/Pause" ]
        , br [] []
        , button
            [ onClick ResetTimer ]
            [ text "Reset" ]
        , br [] []
        , text ("Current interval(minutes): " ++ String.fromInt (model.intervalSeconds // 60))
        , br [] []
        , Html.form [ onSubmit UpdateIntervalMinutes ]
            [ input [ value model.inputtedIntervalMinutes, onInput InputIntervalMinutes ] []
            , button
                []
                [ text "Change" ]
            ]
        ]


viewUsername : String -> Html Msg
viewUsername username =
    li []
        [ img [ src ("https://github.com/" ++ username ++ ".png"), style "width" "32px", style "border-radius" "50%" ] []
        , text username
        , button [ onClick (DeleteUser username) ] [ text "Delete" ]
        ]


getNewUsernames : Model -> Cmd Msg
getNewUsernames model =
    Random.generate GotNewUsernames <| Random.List.shuffle model.usernames


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.mobbing then
        Time.every 1000 Tick

    else
        Sub.none

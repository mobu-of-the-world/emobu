port module Main exposing (Msg(..), main)

import Browser
import Html exposing (Html, br, button, div, form, img, input, label, li, text, ul)
import Html.Attributes exposing (checked, disabled, for, id, placeholder, src, style, type_, value)
import Html.Events exposing (on, onCheck, onClick, onInput, onSubmit)
import Json.Decode
import Json.Encode
import List.Extra
import Model exposing (Model, User, decoder, defaultValues, encode)
import Random
import Random.List
import Time


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
            { defaultValues | users = decodedModel.users }

        Err _ ->
            defaultValues
    , Cmd.none
    )


type Msg
    = InputUsername String
    | AddUser
    | ShuffleUsers
    | GotNewUsers (List User)
    | DeleteUser String
    | Tick Time.Posix
    | InputIntervalMinutes String
    | UpdateInterval
    | ToggleMobbingState
    | ResetTimer
    | FetchGithubAvatarError String
    | ToggleDubugMode Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputUsername input ->
            ( { model | inputtedUsername = input }, Cmd.none )

        InputIntervalMinutes input ->
            ( { model | inputtedIntervalMinutes = input }, Cmd.none )

        AddUser ->
            let
                username : String
                username =
                    String.trim model.inputtedUsername
            in
            ( { model | inputtedUsername = "", users = { username = username, avatarUrl = getGithubAvatarUrl username } :: model.users }, Cmd.none )

        UpdateInterval ->
            let
                newIntervalMinutesMaybe : Maybe Int
                newIntervalMinutesMaybe =
                    String.toInt model.inputtedIntervalMinutes

                newIntervalSeconds : Int
                newIntervalSeconds =
                    case newIntervalMinutesMaybe of
                        Nothing ->
                            model.intervalSeconds

                        Just minutes ->
                            if minutes > 0 then
                                minutes * 60

                            else
                                model.intervalSeconds
            in
            ( { model | intervalSeconds = newIntervalSeconds }, Cmd.none )

        ToggleDubugMode enabled ->
            ( { model | debugMode = enabled, intervalSeconds = 2 }, Cmd.none )

        ShuffleUsers ->
            ( model, getShuffledUsers model )

        GotNewUsers newUsers ->
            ( { model | users = newUsers }, Cmd.none )

        DeleteUser username ->
            ( { model | users = List.filter (\element -> not (element.username == username)) model.users }, Cmd.none )

        ToggleMobbingState ->
            ( { model | mobbing = not model.mobbing }, Cmd.none )

        ResetTimer ->
            ( { model | mobbing = False, elapsedSeconds = 0 }, Cmd.none )

        -- TODO: Consider to change calc with current time intead of incrementing seconds
        Tick _ ->
            let
                newElapsedSeconds : Int
                newElapsedSeconds =
                    model.elapsedSeconds + 1

                timeOver : Bool
                timeOver =
                    newElapsedSeconds >= model.intervalSeconds

                newUsers : List User
                newUsers =
                    if timeOver then
                        List.Extra.swapAt 0 (List.length model.users - 1) model.users

                    else
                        model.users
            in
            ( { model
                | mobbing =
                    if timeOver then
                        False

                    else
                        model.mobbing
                , users = newUsers
                , elapsedSeconds =
                    if timeOver then
                        0

                    else
                        newElapsedSeconds
              }
            , if timeOver then
                playSound "/audio/meow.mp3"

              else
                Cmd.none
            )

        FetchGithubAvatarError username ->
            let
                setFallbackAvatar : Model.User -> Model.User
                setFallbackAvatar user =
                    if user.username == username then
                        { user | avatarUrl = "https://raw.githubusercontent.com/mobu-of-the-world/mobu/main/public/images/default-profile-icon.png" }

                    else
                        user

                newUsers : List Model.User
                newUsers =
                    List.map setFallbackAvatar model.users
            in
            ( { model | users = newUsers }, Cmd.none )


port setStorage : Json.Encode.Value -> Cmd msg


port playSound : String -> Cmd msg


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg oldModel =
    let
        ( newModel, cmds ) =
            update msg oldModel
    in
    ( newModel
    , Cmd.batch [ setStorage (encode newModel), cmds ]
    )


view : Model -> Html Msg
view model =
    div []
        [ form [ onSubmit AddUser ]
            [ input [ value model.inputtedUsername, onInput InputUsername, placeholder "Username", type_ "text" ] []
            , button
                [ disabled (String.isEmpty (String.trim model.inputtedUsername) || List.member (String.trim model.inputtedUsername) (List.map (\user -> user.username) model.users)) ]
                [ text "Add" ]
            ]
        , button
            [ disabled (List.length model.users < 2), onClick ShuffleUsers ]
            [ text "Shuffle" ]
        , ul [] (List.map viewUser model.users)
        , br [] []
        , text ("Elapsed seconds: " ++ String.fromInt model.elapsedSeconds)
        , br [] []
        , text ("Elapsed minutes: " ++ String.fromInt (model.elapsedSeconds // 60))
        , br [] []
        , button
            [ disabled (List.length model.users < 2), onClick ToggleMobbingState ]
            [ text "Start/Pause" ]
        , br [] []
        , button
            [ onClick ResetTimer ]
            [ text "Reset" ]
        , br [] []
        , text ("Current interval(seconds): " ++ String.fromInt model.intervalSeconds)
        , br [] []
        , text ("Current interval(minutes): " ++ String.fromInt (model.intervalSeconds // 60))
        , br [] []
        , Html.form [ onSubmit UpdateInterval ]
            [ input [ value model.inputtedIntervalMinutes, onInput InputIntervalMinutes, type_ "number", Html.Attributes.min "1" ] []
            , button
                [ disabled model.mobbing ]
                [ text "Change" ]
            ]
        , br [] []
        , label [ for "toggle_debug_mode" ]
            [ input [ type_ "checkbox", id "toggle_debug_mode", checked model.debugMode, onCheck ToggleDubugMode ] []
            , text "Debug mode enforces to 2 seconds for the interval"
            ]
        ]


viewUser : User -> Html Msg
viewUser user =
    li []
        [ img [ src user.avatarUrl, style "width" "32px", style "border-radius" "50%", on "error" (Json.Decode.succeed (FetchGithubAvatarError user.username)) ] []
        , text user.username
        , button [ onClick (DeleteUser user.username) ] [ text "Delete" ]
        ]


getGithubAvatarUrl : String -> String
getGithubAvatarUrl username =
    "https://github.com/" ++ username ++ ".png"


getShuffledUsers : Model -> Cmd Msg
getShuffledUsers model =
    Random.generate GotNewUsers <| Random.List.shuffle model.users


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.mobbing then
        Time.every 1000 Tick

    else
        Sub.none

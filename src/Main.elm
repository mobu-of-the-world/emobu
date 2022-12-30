port module Main exposing (Event, Msg(..), main, rotate)

import Browser
import Browser.Dom as Dom
import Duration
import Html exposing (Attribute, Html, a, br, button, div, footer, form, header, img, input, label, li, ol, option, select, span, text)
import Html.Attributes exposing (checked, class, disabled, for, href, id, placeholder, src, title, type_, value)
import Html.Events exposing (on, onCheck, onClick, onInput, onSubmit)
import Json.Decode
import Json.Encode
import MobSession
import Model exposing (Model, PersistedModel, User, decoder, defaultPersistedValues, defaultValues, encode)
import Random
import Random.List
import Task
import Time exposing (Posix, every)


main : Program Json.Encode.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = subscriptions
        }


type alias InitializerFlags =
    { persisted : Maybe PersistedModel, gitRef : String }


appDecoder : Json.Decode.Decoder InitializerFlags
appDecoder =
    Json.Decode.map2 InitializerFlags
        (Json.Decode.maybe (Json.Decode.field "persisted" decoder))
        (Json.Decode.field "gitRef" Json.Decode.string)


init : Json.Encode.Value -> ( Model, Cmd Msg )
init flags =
    ( case Json.Decode.decodeValue appDecoder flags of
        Ok decoded ->
            let
                persisted =
                    Maybe.withDefault defaultPersistedValues decoded.persisted
            in
            { defaultValues
                | users =
                    persisted.users
                        |> List.map (\persistedUser -> { username = persistedUser.username, avatarUrl = getGithubAvatarUrl persistedUser.username })
                , enabledSound = persisted.enabledSound
                , enabledNotification = persisted.enabledNotification
                , intervalSeconds = persisted.intervalSeconds
                , gitRef = decoded.gitRef
            }

        Err _ ->
            defaultValues
    , Cmd.none
    )


type Event
    = Start
    | Stop
    | Stay


type Msg
    = InputUsername String
    | AddUser
    | ShuffleUsers
    | UpdateUsers (List User)
    | Tick Posix
    | UpdateInterval MobSession.IntervalUnit String
    | UpdateMobbing Bool
    | ResetTimer
    | FallbackAvatar String
    | UpdateSoundMode Bool
    | UpdateNotificationMode Bool
    | UpdateDurations Event Posix
    | CheckMobSession
    | NoOp


fallbackAvatarUrl : String
fallbackAvatarUrl =
    "/images/default-profile-icon.png"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputUsername input ->
            ( { model | inputtedUsername = input }, Cmd.none )

        AddUser ->
            ( if isAddableUser model then
                let
                    username =
                        String.trim model.inputtedUsername
                in
                { model
                    | inputtedUsername = ""
                    , users = model.users ++ [ { username = username, avatarUrl = getGithubAvatarUrl username } ]
                }

              else
                model
            , Task.attempt (\_ -> NoOp) (Dom.focus "username-input")
            )

        UpdateInterval unit input ->
            ( { model
                | intervalSeconds =
                    case String.toInt input of
                        Just int ->
                            MobSession.updateIntervalSeconds int unit model.intervalSeconds

                        _ ->
                            model.intervalSeconds
              }
            , Cmd.none
            )

        UpdateSoundMode enabled ->
            ( { model | enabledSound = enabled }, Cmd.none )

        UpdateNotificationMode enabled ->
            ( { model | enabledNotification = enabled }, Cmd.none )

        ShuffleUsers ->
            ( model, Random.generate UpdateUsers <| Random.List.shuffle model.users )

        UpdateUsers newUsers ->
            ( { model | users = newUsers }, Cmd.none )

        UpdateMobbing mobbing ->
            ( { model | mobbing = mobbing }
            , Task.perform
                (UpdateDurations
                    (if model.mobbing == mobbing then
                        Stay

                     else if mobbing then
                        Start

                     else
                        Stop
                    )
                )
                Time.now
            )

        UpdateDurations event moment ->
            ( { model
                | moment = moment
                , durations =
                    case event of
                        Start ->
                            ( moment, moment ) :: model.durations

                        _ ->
                            Duration.updateLatest moment model.durations
              }
            , if event == Stay then
                -- https://medium.com/elm-shorts/how-to-turn-a-msg-into-a-cmd-msg-in-elm-5dd095175d84
                Task.succeed CheckMobSession |> Task.perform identity

              else
                Cmd.none
            )

        ResetTimer ->
            ( { model | mobbing = False, durations = [] }, Cmd.none )

        CheckMobSession ->
            if Duration.elapsedSecondsFromDurations model.durations >= model.intervalSeconds then
                ( { model
                    | mobbing = False
                    , users = rotate model.users
                    , durations = []
                  }
                , Cmd.batch
                    [ if model.enabledSound then
                        playSound "/audio/meow.mp3"

                      else
                        Cmd.none
                    , if model.enabledNotification then
                        notify "🚗 Change the driver! 🚗"

                      else
                        Cmd.none
                    ]
                )

            else
                ( model, Cmd.none )

        Tick _ ->
            ( model
            , Task.perform
                (UpdateDurations Stay)
                Time.now
            )

        FallbackAvatar username ->
            let
                setFallbackAvatar user =
                    { user
                        | avatarUrl =
                            if user.username == username then
                                fallbackAvatarUrl

                            else
                                user.avatarUrl
                    }
            in
            ( { model | users = model.users |> List.map setFallbackAvatar }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )


port setStorage : Json.Encode.Value -> Cmd msg


port playSound : String -> Cmd msg


port notify : String -> Cmd msg


rotate : List items -> List items
rotate items =
    case items of
        head :: rest ->
            rest ++ [ head ]

        _ ->
            items


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg oldModel =
    let
        ( newModel, cmds ) =
            update msg oldModel
    in
    ( newModel
    , Cmd.batch [ setStorage (encode newModel), cmds ]
    )


isAddableUser : Model -> Bool
isAddableUser model =
    let
        normalizedUsername : String
        normalizedUsername =
            String.trim model.inputtedUsername
    in
    not
        (String.isEmpty normalizedUsername
            || List.member normalizedUsername (List.map (\user -> user.username) model.users)
        )


balloon : ( String, String ) -> List (Attribute msg)
balloon ( label, pos ) =
    [ Html.Attributes.attribute "data-balloon-visible" "true"
    , Html.Attributes.attribute "aria-label" label
    , Html.Attributes.attribute "data-balloon-pos" pos
    ]


addUserInput : Model -> Html Msg
addUserInput model =
    div [ class "list-item" ]
        [ li []
            [ form [ onSubmit AddUser ]
                [ input [ id "username-input", value model.inputtedUsername, onInput InputUsername, placeholder "Username", type_ "text" ] []
                , button
                    ((if satisfiedMinMembers model then
                        []

                      else
                        balloon ( "mob needs 2+ members!", "down" )
                     )
                        ++ [ class "button", disabled (not (model |> isAddableUser)) ]
                    )
                    [ emoji "➕" ]
                ]
            ]
        ]


deleteUser : User -> List User -> List User
deleteUser leaver users =
    users |> List.filter (\user -> not (user.username == leaver.username))


userPanel : Model -> Html Msg
userPanel model =
    div [ class "users-panel" ]
        [ ol []
            ((model.users
                |> List.map
                    (\user ->
                        li []
                            [ div [ class "list-item" ]
                                [ img
                                    ([ class "user-image"
                                     , src user.avatarUrl
                                     ]
                                        ++ (if user.avatarUrl == fallbackAvatarUrl then
                                                []

                                            else
                                                [ onError (FallbackAvatar user.username) ]
                                           )
                                    )
                                    []
                                , text user.username
                                , button [ onClick (UpdateUsers (model.users |> deleteUser user)), class "button" ] [ emoji "👋" ]
                                ]
                            ]
                    )
             )
                ++ [ addUserInput model ]
            )
        ]


newIntervalFields : Model -> Html Msg
newIntervalFields model =
    let
        ( hoursOptions, minutesOptions, secondsOptions ) =
            MobSession.newIntervalOptions model.intervalSeconds

        optionsFormatter =
            List.map
                (\( val, selected ) -> option [ value val, Html.Attributes.selected selected ] [ text val ])
    in
    div [ class "interval-input" ]
        [ text "/"
        , space
        , select
            [ class "value-select"
            , onInput (UpdateInterval MobSession.Hour)
            , disabled model.mobbing
            ]
            (hoursOptions |> optionsFormatter)
        , text ":"
        , select
            [ class "value-select"
            , onInput (UpdateInterval MobSession.Min)
            , disabled model.mobbing
            ]
            (minutesOptions |> optionsFormatter)
        , text ":"
        , select
            [ class "value-select"
            , onInput (UpdateInterval MobSession.Sec)
            , disabled model.mobbing
            ]
            (secondsOptions |> optionsFormatter)
        ]


emoji : String -> Html msg
emoji str =
    span [ class "standardized-emoji" ] [ text str ]


satisfiedMinMembers : Model -> Bool
satisfiedMinMembers model =
    List.length model.users >= 2


isReadyMobbing : Model -> Bool
isReadyMobbing model =
    satisfiedMinMembers model && (model.intervalSeconds > 0)


timerPanel : Model -> Html Msg
timerPanel model =
    div [ class "timer-panel" ]
        [ button
            [ title
                (if model.mobbing then
                    "Pause"

                 else
                    "Start"
                )
            , class "button major"
            , disabled (not (isReadyMobbing model))
            , onClick (UpdateMobbing (not model.mobbing))
            ]
            [ emoji "⏯️" ]
        , button
            [ title "Shuffle"
            , class "button major"
            , disabled (model.mobbing || not (satisfiedMinMembers model))
            , onClick ShuffleUsers
            ]
            [ emoji "🔀" ]
        , button
            [ title "Reset", class "button major", onClick ResetTimer ]
            [ emoji "↩️" ]
        , div
            [ title
                (if model.enabledSound then
                    "Mute"

                 else
                    "Enable sound"
                )
            , class "feature-toggle sound-toggle"
            ]
            [ input
                [ type_ "checkbox"
                , id "sound-toggle"
                , checked model.enabledSound
                , onCheck UpdateSoundMode
                ]
                []
            , label [ for "sound-toggle" ] []
            ]
        , div
            [ title
                (if model.enabledNotification then
                    "Disable notifications"

                 else
                    "Enable notification (if you approve)"
                )
            , class "feature-toggle notification-toggle"
            ]
            [ input
                [ type_ "checkbox"
                , id "notification-toggle"
                , checked model.enabledNotification
                , onCheck UpdateNotificationMode
                ]
                []
            , label [ for "notification-toggle" ] []
            ]
        , br [] []
        , div [ class "timer-row" ]
            [ emoji "⏲️"
            , space
            , text (MobSession.readableElapsed (Duration.elapsedSecondsFromDurations model.durations))
            ]
        , newIntervalFields model
        ]


space : Html msg
space =
    span [ class "chars-space" ] []


appHeader : Html msg
appHeader =
    header [ class "header" ]
        [ text "emobu"
        , a [ href "https://github.com/mobu-of-the-world/emobu/" ] [ img [ class "github-logo", src "/images/github-mark.svg" ] [] ]
        ]


appFooter : Model -> Html msg
appFooter model =
    footer [ class "footer" ]
        [ div [ class "footer-body" ]
            [ text "rev - "
            , a
                [ class "revision-link"
                , href ("https://github.com/mobu-of-the-world/emobu/tree/" ++ model.gitRef)
                ]
                [ text model.gitRef ]
            ]
        ]


view : Model -> Html Msg
view model =
    div [ id "page" ]
        [ appHeader
        , userPanel model
        , timerPanel model
        , appFooter model
        ]


onError : msg -> Attribute msg
onError msg =
    on "error" (Json.Decode.succeed msg)


getGithubAvatarUrl : String -> String
getGithubAvatarUrl username =
    "https://github.com/" ++ username ++ ".png"


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.mobbing then
        -- Should be less than 1 sec. No actual interval. Ref: https://github.com/mobu-of-the-world/mobu/pull/486
        every 500 Tick

    else
        Sub.none

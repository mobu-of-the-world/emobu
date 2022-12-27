port module Main exposing (DurationForEachUnit, DurationUnit, Msg(..), main, rotate)

import Browser
import Html exposing (Attribute, Html, a, br, button, div, footer, form, header, img, input, label, li, ol, option, select, span, text)
import Html.Attributes exposing (checked, class, disabled, for, href, id, placeholder, src, type_, value)
import Html.Events exposing (on, onCheck, onClick, onInput, onSubmit)
import Json.Decode
import Json.Encode
import Model exposing (Model, PersistedModel, User, decoder, defaultPersistedValues, defaultValues, encode)
import Random
import Random.List
import Time exposing (Posix, every, millisToPosix, toHour, toMinute, toSecond, utc)


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
                , intervalSeconds = persisted.intervalSeconds
                , gitRef = decoded.gitRef
            }

        Err _ ->
            defaultValues
    , Cmd.none
    )


type alias DurationForEachUnit =
    { hour : Int
    , min : Int
    , sec : Int
    }


type DurationUnit
    = Hour
    | Min
    | Sec


radixToSeconds : DurationUnit -> Int
radixToSeconds unit =
    case unit of
        Hour ->
            60 * 60

        Min ->
            60

        Sec ->
            1


type Msg
    = InputUsername String
    | AddUser
    | ShuffleUsers
    | ReplaceUsers (List User)
    | DeleteUser String
    | Tick Posix
    | UpdateInterval DurationUnit String
    | ToggleMobbingState
    | ResetTimer
    | FetchGithubAvatarError String
    | ToggleSoundMode Bool


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
            , Cmd.none
            )

        UpdateInterval unit input ->
            let
                currentInterval =
                    secondsToInterval model.intervalSeconds

                currentInUnit =
                    case unit of
                        Hour ->
                            currentInterval.hour

                        Min ->
                            currentInterval.min

                        Sec ->
                            currentInterval.sec

                newInUnit =
                    Maybe.withDefault currentInUnit (String.toInt input)

                diff =
                    newInUnit - currentInUnit

                radix =
                    radixToSeconds unit
            in
            ( { model | intervalSeconds = model.intervalSeconds + (diff * radix) }, Cmd.none )

        ToggleSoundMode enabled ->
            ( { model | enabledSound = enabled }, Cmd.none )

        ShuffleUsers ->
            ( model, Random.generate ReplaceUsers <| Random.List.shuffle model.users )

        ReplaceUsers newUsers ->
            ( { model | users = newUsers }, Cmd.none )

        DeleteUser username ->
            ( { model | users = List.filter (\element -> not (element.username == username)) model.users }, Cmd.none )

        ToggleMobbingState ->
            ( { model | mobbing = not model.mobbing }, Cmd.none )

        ResetTimer ->
            ( { model | mobbing = False, elapsedSeconds = 0 }, Cmd.none )

        -- TODO: Consider to change calc with current time intead of incrementing seconds. In react https://github.com/mobu-of-the-world/mobu/pull/486
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
                        rotate model.users

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
            , if timeOver && model.enabledSound then
                playSound "/audio/meow.mp3"

              else
                Cmd.none
            )

        FetchGithubAvatarError username ->
            let
                setFallbackAvatar : Model.User -> Model.User
                setFallbackAvatar user =
                    if user.username == username then
                        { user | avatarUrl = fallbackAvatarUrl }

                    else
                        user

                newUsers : List Model.User
                newUsers =
                    List.map setFallbackAvatar model.users
            in
            ( { model | users = newUsers }, Cmd.none )


port setStorage : Json.Encode.Value -> Cmd msg


port playSound : String -> Cmd msg


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
                [ input [ class "add-input", value model.inputtedUsername, onInput InputUsername, placeholder "Username", type_ "text" ] []
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


userPanel : Model -> Html Msg
userPanel model =
    div [ class "users-panel" ]
        [ ol []
            (List.map userRow model.users
                ++ [ addUserInput model ]
            )
        ]


readableDuration : Int -> String
readableDuration seconds =
    let
        time : Posix
        time =
            millisToPosix (seconds * 1000)
    in
    String.padLeft 2 '0' (String.fromInt (toHour utc time))
        ++ ":"
        ++ String.padLeft 2 '0' (String.fromInt (toMinute utc time))
        ++ ":"
        ++ String.padLeft 2 '0' (String.fromInt (toSecond utc time))


secondsToInterval : Int -> DurationForEachUnit
secondsToInterval totalSeconds =
    let
        sec =
            remainderBy 60 totalSeconds

        hour =
            totalSeconds // (60 * 60)

        min =
            (totalSeconds // 60) - (hour * 60)
    in
    DurationForEachUnit hour min sec


formatDurationUnit : Int -> String
formatDurationUnit val =
    String.padLeft 2 '0' (String.fromInt val)


newIntervalFields : Model -> Html Msg
newIntervalFields model =
    div [ class "interval-input" ]
        [ text "/"
        , space
        , select
            [ class "value-select"
            , onInput (UpdateInterval Hour)
            , disabled model.mobbing
            ]
            (List.range
                0
                2
                |> List.map
                    (\int ->
                        let
                            padStr =
                                formatDurationUnit int

                            current =
                                (secondsToInterval model.intervalSeconds).hour == int
                        in
                        option [ value padStr, Html.Attributes.selected current ] [ text padStr ]
                    )
            )
        , text ":"
        , select
            [ class "value-select"
            , onInput (UpdateInterval Min)
            , disabled model.mobbing
            ]
            (List.range
                0
                59
                |> List.filter (\item -> (item |> remainderBy 5) == 0)
                |> List.map
                    (\int ->
                        let
                            padStr =
                                formatDurationUnit int

                            current =
                                (secondsToInterval model.intervalSeconds).min == int
                        in
                        option [ value padStr, Html.Attributes.selected current ] [ text padStr ]
                    )
            )
        , text ":"
        , select
            [ class "value-select"
            , onInput (UpdateInterval Sec)
            , disabled model.mobbing
            ]
            (List.range
                0
                59
                |> List.filter (\item -> (item |> remainderBy 5) == 0)
                |> List.map
                    (\int ->
                        let
                            padStr =
                                formatDurationUnit int

                            current =
                                (secondsToInterval model.intervalSeconds).sec == int
                        in
                        option [ value padStr, Html.Attributes.selected current ] [ text padStr ]
                    )
            )
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
            [ class "button major"
            , disabled (not (isReadyMobbing model))
            , onClick ToggleMobbingState
            ]
            [ emoji "⏯️" ]
        , button
            [ class "button major"
            , disabled (model.mobbing || not (satisfiedMinMembers model))
            , onClick ShuffleUsers
            ]
            [ emoji "🔀" ]
        , button
            [ class "button major", onClick ResetTimer ]
            [ emoji "↩️" ]
        , div [ class "sound-toggle" ]
            [ input [ type_ "checkbox", id "sound-toggle", checked model.enabledSound, onCheck ToggleSoundMode ] []
            , label [ for "sound-toggle" ] []
            ]
        , br [] []
        , div [ class "timer-row" ]
            [ emoji "⏲️"
            , space
            , text (readableDuration model.elapsedSeconds)
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
        [ text "rev - ", a [ class "revision-link", href ("https://github.com/mobu-of-the-world/emobu/tree/" ++ model.gitRef) ] [ text model.gitRef ] ]


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


userRow : User -> Html Msg
userRow user =
    li []
        [ div [ class "list-item" ]
            [ img
                ([ class "user-image"
                 , src user.avatarUrl
                 ]
                    ++ (if user.avatarUrl == fallbackAvatarUrl then
                            []

                        else
                            [ onError (FetchGithubAvatarError user.username) ]
                       )
                )
                []
            , text user.username
            , button [ onClick (DeleteUser user.username), class "button" ] [ emoji "👋" ]
            ]
        ]


getGithubAvatarUrl : String -> String
getGithubAvatarUrl username =
    "https://github.com/" ++ username ++ ".png"


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.mobbing then
        every 1000 Tick

    else
        Sub.none

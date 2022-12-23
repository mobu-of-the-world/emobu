module Page.App exposing (view)

import Html exposing (Html, a, br, button, div, footer, form, header, img, input, label, li, span, text, ul)
import Html.Attributes exposing (checked, class, disabled, for, href, id, placeholder, src, type_, value)
import Html.Events exposing (on, onCheck, onClick, onInput, onSubmit)
import Json.Decode
import Messages exposing (Msg(..))
import Model exposing (Model, User)
import Time exposing (Posix, millisToPosix, toHour, toMinute, toSecond, utc)


userPanel : Model -> Html Msg
userPanel model =
    div [ class "users-panel" ]
        [ ul []
            (List.map viewUser model.users
                ++ [ div [ class "list-item" ]
                        [ li []
                            [ form [ onSubmit AddUser ]
                                [ input [ class "add-input", value model.inputtedUsername, onInput InputUsername, placeholder "Username", type_ "text" ] []
                                , button
                                    [ class "emoji-button", disabled (String.isEmpty (String.trim model.inputtedUsername) || List.member (String.trim model.inputtedUsername) (List.map (\user -> user.username) model.users)) ]
                                    [ text "➕" ]
                                ]
                            ]
                        ]
                   ]
            )
        ]


view : Model -> Html Msg
view model =
    div [ id "page" ]
        [ appHeader
        , userPanel model
        , timerPanel model
        , appFooter model
        ]


viewUser : User -> Html Msg
viewUser user =
    li []
        [ div [ class "list-item" ]
            [ img [ class "user-image", src user.avatarUrl, on "error" (Json.Decode.succeed (FetchGithubAvatarError user.username)) ] []
            , text user.username
            , button [ onClick (DeleteUser user.username), class "emoji-button" ] [ text "👋" ]
            ]
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


timerPanel : Model -> Html Msg
timerPanel model =
    div [ class "timer-panel" ]
        [ button
            [ class "emoji-button major", disabled (List.length model.users < 2), onClick ToggleMobbingState ]
            [ text "⏯️" ]
        , button [ class "emoji-button major", disabled (List.length model.users < 2), onClick ShuffleUsers ] [ text "🔀" ]
        , button
            [ class "emoji-button major", onClick ResetTimer ]
            [ text "↩️" ]
        , br [] []
        , text ("⏲️ " ++ readableDuration model.elapsedSeconds ++ "/" ++ readableDuration model.intervalSeconds)
        , div [ class "newinterval-row" ]
            [ span [] [ text "➡" ]
            , Html.form [ onSubmit UpdateInterval ]
                [ input [ class "minutes-input", value model.inputtedIntervalMinutes, onInput InputIntervalMinutes, type_ "number", Html.Attributes.min "1", disabled model.debugMode ] []
                , span [ class "unit-label" ] [ text "min" ]
                , button
                    [ class "emoji-button", disabled (model.mobbing || model.debugMode || model.inputtedIntervalMinutes == String.fromInt (model.intervalSeconds // 60)) ]
                    [ text "✔️" ]
                ]
            ]
        , div [ class "debug-toggle" ]
            [ label [ for "toggle_debug_mode" ]
                [ input [ type_ "checkbox", id "toggle_debug_mode", checked model.debugMode, onCheck ToggleDubugMode ] []
                , text "Debug mode (2 seconds)"
                ]
            ]
        ]


appHeader : Html msg
appHeader =
    header [ class "header" ]
        [ text "emobu"
        , a [ href "https://github.com/mobu-of-the-world/emobu/" ] [ img [ class "github-logo", src "/images/github-mark.svg" ] [] ]
        ]


appFooter : Model -> Html msg
appFooter model =
    footer [ class "footer" ]
        [ text "rev - ", a [ class "revision-link", href ("https://github.com/mobu-of-the-world/emobu/tree/" ++ model.commitRef) ] [ text model.commitRef ] ]

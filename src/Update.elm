port module Update exposing (updateWithStorage)

import Json.Encode
import List exposing (drop, take)
import Messages exposing (Msg(..))
import Model exposing (Model, User, encode)
import Random
import Random.List


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
            ( { model | inputtedUsername = "", users = model.users ++ [ { username = username, avatarUrl = getGithubAvatarUrl username } ] }, Cmd.none )

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
                        drop 1 model.users ++ take 1 model.users

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


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg oldModel =
    let
        ( newModel, cmds ) =
            update msg oldModel
    in
    ( newModel
    , Cmd.batch [ setStorage (encode newModel), cmds ]
    )


getShuffledUsers : Model -> Cmd Msg
getShuffledUsers model =
    Random.generate GotNewUsers <| Random.List.shuffle model.users


getGithubAvatarUrl : String -> String
getGithubAvatarUrl username =
    "https://github.com/" ++ username ++ ".png"


port setStorage : Json.Encode.Value -> Cmd msg


port playSound : String -> Cmd msg

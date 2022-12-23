module Messages exposing (Msg(..))

import Model exposing (User)
import Time exposing (Posix)


type Msg
    = InputUsername String
    | AddUser
    | ShuffleUsers
    | GotNewUsers (List User)
    | DeleteUser String
    | Tick Posix
    | InputIntervalMinutes String
    | UpdateInterval
    | ToggleMobbingState
    | ResetTimer
    | FetchGithubAvatarError String
    | ToggleDubugMode Bool

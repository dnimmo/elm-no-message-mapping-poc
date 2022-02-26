port module User exposing (User, fetchUser, userReceived)


type alias User =
    String


port fetchUser : Bool -> Cmd msg


port userReceived : (String -> msg) -> Sub msg

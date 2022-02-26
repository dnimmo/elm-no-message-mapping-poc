port module User exposing (..)


port fetchUser : Bool -> Cmd msg


port userReceived : (String -> msg) -> Sub msg

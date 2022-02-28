port module User exposing
    ( User
    , decode
    , errorRetrievingUser
    , fetchUser
    , saveUsername
    , signOut
    , updateName
    , userReceived
    )

import Json.Decode as Decode exposing (Decoder, field, int, string)


type alias User =
    { name : String
    , email : String
    , userId : Int
    , password : String
    }


updateName : String -> User -> User
updateName newName user =
    { user | name = newName }



-- DECODE


decode : Decoder User
decode =
    Decode.map4 User
        (field "name" string)
        (field "email" string)
        (field "userId" int)
        (field "password" string)



-- OUTGOING


port fetchUser : { email : String, password : String } -> Cmd msg


port saveUsername : String -> Cmd msg


port signOut : () -> Cmd msg



-- INCOMING


port userReceived : (Decode.Value -> msg) -> Sub msg


port errorRetrievingUser : (String -> msg) -> Sub msg


port notLoggedIn : (() -> msg) -> Sub msg

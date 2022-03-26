port module User exposing
    ( Model
    , User
    , decode
    , errorRetrievingUser
    , fetchUser
    , getUser
    , init
    , isLoggedIn
    , saveUsername
    , signOut
    , updateName
    , userReceived
    )

import Json.Decode as Decode exposing (Decoder, field, int, string)



-- MODEL


type Model
    = NotLoggedIn
    | LoggedIn User


type alias User =
    { name : String
    , email : String
    , userId : Int
    , password : String
    }


updateName : String -> User -> User
updateName newName user =
    { user | name = newName }


isLoggedIn : Model -> Bool
isLoggedIn model =
    model /= NotLoggedIn


getUser : Model -> Maybe User
getUser model =
    case model of
        NotLoggedIn ->
            Nothing

        LoggedIn user ->
            Just user



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



-- INIT


init : Maybe User -> Model
init maybeUser =
    case maybeUser of
        Just user ->
            LoggedIn user

        Nothing ->
            NotLoggedIn

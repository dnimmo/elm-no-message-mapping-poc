port module User exposing
    ( Model
    , Msg
    , User
    , decode
    , errorRetrievingUser
    , fetchUser
    , getUser
    , init
    , isLoggedIn
    , saveUsername
    , signOut
    , signOutAttemptFailed
    , signedOutSuccessfully
    , storedUserUpdated
    , subscriptions
    , update
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



-- UPDATE


type Msg
    = StoredUserUpdated (Result Decode.Error User)
    | LoggedOut ()


update : Msg -> Model -> Model
update msg model =
    case msg of
        LoggedOut _ ->
            NotLoggedIn

        StoredUserUpdated (Ok user) ->
            LoggedIn user

        -- TODO Re-route to error page in this scenario
        StoredUserUpdated (Err _) ->
            NotLoggedIn



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


port signedOutSuccessfully : (() -> msg) -> Sub msg


port signOutAttemptFailed : (String -> msg) -> Sub msg


port storedUserUpdated : (Decode.Value -> msg) -> Sub msg



-- INIT


init : Maybe User -> Model
init maybeUser =
    case maybeUser of
        Just user ->
            LoggedIn user

        Nothing ->
            NotLoggedIn


storedUserUpdatedMsg : Decode.Value -> Msg
storedUserUpdatedMsg =
    StoredUserUpdated << Decode.decodeValue decode


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ storedUserUpdated storedUserUpdatedMsg
        , signedOutSuccessfully LoggedOut
        , userReceived storedUserUpdatedMsg
        ]

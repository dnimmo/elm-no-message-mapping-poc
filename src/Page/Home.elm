module Page.Home exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation as Nav
import Components.Input as Input
import Components.Layout as Layout
import Element exposing (..)
import Json.Decode as Decode
import Route
import User exposing (User)



-- MODEL


type State
    = ViewingSignInForm
    | ViewingSignInFormWithError String
    | Loading


type alias Model =
    { state : State
    , email : String
    , password : String
    }



-- UPDATE


type Msg
    = UpdateEmail String
    | UpdatePassword String
    | AttemptSignIn
    | SignInFailed String
    | SignInResponseReceived (Result Decode.Error User)


handleEmailUpdate : Model -> String -> Model
handleEmailUpdate model str =
    { model | email = str }


handlePasswordUpdate : Model -> String -> Model
handlePasswordUpdate model str =
    { model | password = str }


handleSignInAttempt : Model -> ( Model, Cmd Msg )
handleSignInAttempt model =
    ( { model | state = Loading }
    , User.fetchUser
        { email = model.email
        , password = model.password
        }
    )


handleSignInFailure : Model -> String -> Model
handleSignInFailure model str =
    { model | state = ViewingSignInFormWithError str }


handleSignInResult : Model -> Result Decode.Error User -> Nav.Key -> ( Model, Cmd Msg )
handleSignInResult model result navKey =
    case result of
        Ok _ ->
            ( model
            , Route.pushUrl navKey Route.Dashboard
            )

        Err err ->
            ( { model | state = ViewingSignInFormWithError <| Decode.errorToString err }
            , Cmd.none
            )


update : Msg -> Model -> Nav.Key -> ( Model, Cmd Msg )
update msg model navKey =
    case msg of
        UpdateEmail str ->
            ( handleEmailUpdate model str
            , Cmd.none
            )

        UpdatePassword str ->
            ( handlePasswordUpdate model str, Cmd.none )

        AttemptSignIn ->
            handleSignInAttempt model

        SignInFailed str ->
            ( handleSignInFailure model str
            , Cmd.none
            )

        SignInResponseReceived result ->
            handleSignInResult model result navKey



-- VIEW


view : Model -> Element Msg
view model =
    column
        [ width fill
        , spacing 20
        , paddingXY 50 200
        ]
        [ Layout.pageHeader { currentRoute = Route.Home, parentRoute = Nothing }
        , Input.email UpdateEmail
            { labelText = "Email address"
            , value = model.email
            }
        , Input.currentPassword UpdatePassword
            { labelText = "Password"
            , value = model.password
            , show = False
            }
        , case model.state of
            Loading ->
                none

            _ ->
                Input.positiveButton "Sign in" AttemptSignIn
        , case model.state of
            ViewingSignInFormWithError str ->
                text <| "An error has occurred: " ++ str

            _ ->
                none
        ]



-- INIT


init : Model
init =
    { state = ViewingSignInForm
    , email = ""
    , password = ""
    }


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ User.errorRetrievingUser SignInFailed
        , User.userReceived <|
            SignInResponseReceived
                << Decode.decodeValue User.decode
        ]

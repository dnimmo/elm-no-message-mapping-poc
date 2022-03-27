module Page.SignOut exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Navigation as Nav
import Components.Layout as Layout
import Element exposing (..)
import Route
import User exposing (User)



-- MODEL


type Model
    = Model User State


type State
    = AttemptingToSignOut
    | FatalError String



-- UPDATE


type Msg
    = SignedOutSuccessfully ()
    | SignOutAttemptFailed String


handleSignOutSuccess : Model -> Nav.Key -> ( Model, Cmd Msg )
handleSignOutSuccess model navKey =
    ( model
    , Route.pushUrl navKey Route.Home
    )


handleSignOutFailure : Model -> String -> Model
handleSignOutFailure (Model account _) str =
    Model account <| FatalError str


update : Msg -> Model -> Nav.Key -> ( Model, Cmd Msg )
update msg model navKey =
    case msg of
        SignedOutSuccessfully _ ->
            handleSignOutSuccess model navKey

        SignOutAttemptFailed str ->
            ( handleSignOutFailure model str
            , Cmd.none
            )



-- VIEW


view : Model -> Element msg
view (Model _ state) =
    case state of
        AttemptingToSignOut ->
            el [] <| text "Signing out..."

        FatalError message ->
            el [] <| text <| "Something has gone wrong: " ++ message



-- INIT


init : User -> ( Model, Cmd Msg )
init user =
    ( Model user AttemptingToSignOut
    , User.signOut ()
    )


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ User.signedOutSuccessfully SignedOutSuccessfully
        , User.signOutAttemptFailed SignOutAttemptFailed
        ]

module Page.Home exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation exposing (Key)
import Components.Input as Input
import Components.Layout as Layout
import Element exposing (..)
import Json.Decode exposing (Error, decodeValue, errorToString)
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
    | UserReceived (Result Error User)
    | SignInFailed String


update : Key -> Msg -> Model -> ( Model, Cmd msg, Maybe User )
update navKey msg model =
    case msg of
        UpdateEmail str ->
            ( { model | email = str }, Cmd.none, Nothing )

        UpdatePassword str ->
            ( { model | password = str }, Cmd.none, Nothing )

        AttemptSignIn ->
            ( { model | state = Loading }
            , User.fetchUser
                { email = model.email
                , password = model.password
                }
            , Nothing
            )

        UserReceived (Ok user) ->
            ( model, Route.replaceUrl navKey <| Route.Dashboard, Just user )

        UserReceived (Err error) ->
            ( { model | state = ViewingSignInFormWithError <| errorToString error }, Cmd.none, Nothing )

        SignInFailed str ->
            ( { model | state = ViewingSignInFormWithError str }, Cmd.none, Nothing )



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
        [ User.userReceived (UserReceived << decodeValue User.decode)
        , User.errorRetrievingUser SignInFailed
        ]

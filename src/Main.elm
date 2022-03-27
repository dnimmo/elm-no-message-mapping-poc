module Main exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Components.Layout as Layout
import Element exposing (..)
import Page.Account as Account
import Page.Dashboard as Dashboard
import Page.Error as Error
import Page.Home as Home
import Page.SignOut as SignOut
import Route exposing (Route(..))
import Url exposing (Url)
import User exposing (User)



-- MODEL


type alias Model =
    { navKey : Nav.Key
    , state : State
    , user : User.Model
    }


type State
    = Loading
    | ViewingHomePage Home.Model
    | ViewingDashboard Dashboard.Model
    | ViewingAccount Account.Model
    | ViewingSignOut SignOut.Model
    | ViewingErrorPage String



-- UPDATE


type Msg
    = UrlChanged Url
    | UrlRequested Browser.UrlRequest
    | UserMsg User.Msg
    | HomeMsg Home.Msg
    | AccountMsg Account.Msg
    | SignOutMsg SignOut.Msg


handleInitialLanding : Model -> ( Model, Cmd Msg )
handleInitialLanding model =
    if User.isLoggedIn model.user then
        ( model
        , Route.pushUrl model.navKey Route.Dashboard
        )

    else
        ( { model
            | state = ViewingHomePage Home.init
          }
        , Cmd.none
        )


handleUrlChange : Url -> Model -> ( Model, Cmd Msg )
handleUrlChange url model =
    case Route.parseRoute url of
        Error str ->
            ( { model
                | state = ViewingErrorPage <| Maybe.withDefault "No message received" str
              }
            , Cmd.none
            )

        Home ->
            handleInitialLanding model

        Dashboard ->
            case User.getUser model.user of
                Just user ->
                    ( { model
                        | state =
                            ViewingDashboard <|
                                Dashboard.init user
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model
                    , Route.pushUrl model.navKey <|
                        Route.Error <|
                            Just "Attempted to view dashboard when not signed in"
                    )

        Account ->
            case User.getUser model.user of
                Just user ->
                    ( { model
                        | state = ViewingAccount <| Account.init user
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model
                    , Route.pushUrl model.navKey <|
                        Route.Error <|
                            Just "Attempted to view account when not signed in"
                    )

        SignOut ->
            case User.getUser model.user of
                Just user ->
                    let
                        ( signOutModel, signOutCmd ) =
                            SignOut.init user
                    in
                    ( { model
                        | state = ViewingSignOut signOutModel
                      }
                    , Cmd.map SignOutMsg signOutCmd
                    )

                Nothing ->
                    ( model
                    , Route.pushUrl model.navKey <|
                        Route.Error <|
                            Just "Attempted to sign out when not signed in"
                    )


handleUserMsg : User.Msg -> Model -> Model
handleUserMsg msg model =
    { model
        | user = User.update msg model.user
    }


handleHomeMsg : Home.Msg -> Model -> ( Model, Cmd Msg )
handleHomeMsg msg model =
    case model.state of
        ViewingHomePage homeModel ->
            let
                ( updatedHomeModel, homeCmd ) =
                    Home.update msg homeModel model.navKey
            in
            ( { model
                | state = ViewingHomePage updatedHomeModel
              }
            , Cmd.map HomeMsg homeCmd
            )

        _ ->
            ( model
            , pageStateError model.navKey "Home"
            )


handleAccountMsg : Account.Msg -> Model -> ( Model, Cmd Msg )
handleAccountMsg msg model =
    case model.state of
        ViewingAccount accountModel ->
            let
                ( updatedAccountState, accountCmd ) =
                    Account.update msg accountModel
            in
            ( { model
                | state = ViewingAccount updatedAccountState
              }
            , Cmd.map AccountMsg accountCmd
            )

        _ ->
            ( model
            , pageStateError model.navKey "Account"
            )


handleSignOutMsg : SignOut.Msg -> Model -> ( Model, Cmd Msg )
handleSignOutMsg msg model =
    case model.state of
        ViewingSignOut signOutModel ->
            let
                ( updatedSignOutModel, signOutCmd ) =
                    SignOut.update msg signOutModel model.navKey
            in
            ( { model | state = ViewingSignOut updatedSignOutModel }
            , Cmd.map SignOutMsg signOutCmd
            )

        _ ->
            ( model
            , pageStateError model.navKey "SignOut"
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            handleUrlChange url model

        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    -- This will cause `UrlChanged` to be fired, which will then handle the URL change
                    -- The reason I didn't call handleUrlChange directly here was to ensure that the URL in the address bar is correctly updated
                    ( model, Route.pushUrl model.navKey <| Route.parseRoute url )

                Browser.External urlString ->
                    ( model, Nav.load urlString )

        UserMsg userMsg ->
            ( handleUserMsg userMsg model
            , Cmd.none
            )

        HomeMsg homeMsg ->
            handleHomeMsg homeMsg model

        AccountMsg accountMsg ->
            handleAccountMsg accountMsg model

        SignOutMsg signOutMsg ->
            handleSignOutMsg signOutMsg model



-- VIEW


pageStateError : Nav.Key -> String -> Cmd Msg
pageStateError navKey str =
    Route.pushUrl navKey <|
        Route.Error <|
            Just <|
                "Attempted to handle "
                    ++ str
                    ++ " message whilst not viewing "
                    ++ str


loadingView : Element msg
loadingView =
    text "Loading..."


view : Model -> Browser.Document Msg
view model =
    { title = "POC"
    , body =
        [ Layout.global <|
            column [ width fill ]
                [ Layout.header model.user
                , Layout.page <|
                    case model.state of
                        Loading ->
                            loadingView

                        ViewingHomePage homeModel ->
                            Element.map HomeMsg <|
                                Home.view homeModel

                        ViewingDashboard dashboardModel ->
                            Dashboard.view dashboardModel

                        ViewingAccount accountModel ->
                            Element.map AccountMsg <|
                                Account.view accountModel

                        ViewingSignOut signOutModel ->
                            SignOut.view signOutModel

                        ViewingErrorPage str ->
                            Error.view model.user str
                ]
        ]
    }



-- INIT


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init { user } url navKey =
    let
        startingModel =
            { navKey = navKey
            , state = Loading
            , user = User.init user
            }

        ( initialModel, initialCmd ) =
            handleUrlChange url startingModel
    in
    ( initialModel
    , initialCmd
    )


type alias Flags =
    { user : Maybe User }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Sub.map UserMsg User.subscriptions
        , Sub.map HomeMsg Home.subscriptions
        , Sub.map AccountMsg Account.subscriptions
        , Sub.map SignOutMsg SignOut.subscriptions
        ]


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }

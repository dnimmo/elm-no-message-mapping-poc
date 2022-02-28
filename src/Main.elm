module Main exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Components.Layout as Layout
import Element exposing (..)
import Json.Decode exposing (decodeValue, errorToString)
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
    , user : Maybe User
    }


type State
    = Loading
    | ViewingHomePage Home.Model
    | ViewingDashboard
    | ViewingAccount Account.State
    | ViewingSignOut
    | ViewingErrorPage String



-- UPDATE


type Msg
    = UrlChanged Url
    | UrlRequested Browser.UrlRequest
    | UserReceived (Result Json.Decode.Error User)
    | HomeMsg Home.Msg
    | AccountMsg Account.Msg


handleInitialLanding : Model -> ( Model, Cmd Msg )
handleInitialLanding model =
    case model.user of
        Just _ ->
            ( model
            , Route.replaceUrl model.navKey Route.Dashboard
            )

        Nothing ->
            ( { model
                | state = ViewingHomePage Home.init
                , user = Nothing
              }
            , Cmd.none
            )


handleUrlChange : Url -> Model -> ( Model, Cmd Msg )
handleUrlChange url model =
    case Route.parseRoute url of
        Error ->
            ( { model | state = ViewingErrorPage "Page not found" }, Cmd.none )

        Home ->
            handleInitialLanding model

        Dashboard ->
            ( { model | state = ViewingDashboard }, Cmd.none )

        Account ->
            ( { model | state = ViewingAccount Account.init }, Cmd.none )

        SignOut ->
            ( { model
                | state = ViewingSignOut
                , user = Nothing
              }
            , User.signOut ()
            )


handleUserResponse : Result Json.Decode.Error User -> Model -> ( Model, Cmd Msg )
handleUserResponse response model =
    case response of
        Ok user ->
            ( { model | user = Just user }
            , case model.state of
                ViewingHomePage _ ->
                    Route.replaceUrl model.navKey Dashboard

                _ ->
                    Nav.reload
            )

        Err error ->
            ( { model | state = ViewingErrorPage <| errorToString error }, Cmd.none )


handleHomeMsg : Home.Msg -> Model -> ( Model, Cmd Msg )
handleHomeMsg msg model =
    case model.state of
        ViewingHomePage homeModel ->
            let
                ( updatedHomeModel, homeCmd ) =
                    Home.update msg homeModel
            in
            ( { model
                | state = ViewingHomePage updatedHomeModel
              }
            , Cmd.map HomeMsg homeCmd
            )

        _ ->
            ( { model | state = ViewingErrorPage <| pageStateError "Home" }
            , Cmd.none
            )


handleAccountMsg : Account.Msg -> Model -> ( Model, Cmd Msg )
handleAccountMsg msg model =
    case model.state of
        ViewingAccount _ ->
            let
                ( updatedAccountState, accountCmd ) =
                    Account.update msg
            in
            ( { model
                | state = ViewingAccount updatedAccountState
              }
            , accountCmd
            )

        _ ->
            ( { model
                | state = ViewingErrorPage <| pageStateError "account"
              }
            , Cmd.none
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
                    ( model, Route.replaceUrl model.navKey <| Route.parseRoute url )

                Browser.External urlString ->
                    ( model, Nav.load urlString )

        UserReceived response ->
            handleUserResponse response model

        HomeMsg homeMsg ->
            handleHomeMsg homeMsg model

        AccountMsg accountMsg ->
            handleAccountMsg accountMsg model



-- VIEW


pageStateError : String -> String
pageStateError str =
    "Attempted to handle " ++ str ++ " message whilst not viewing " ++ str


loadingView : Element msg
loadingView =
    text "Loading..."


handleAuthenticatedView : Model -> (User -> Element Msg) -> Element Msg
handleAuthenticatedView model requestedView =
    case model.user of
        Just user ->
            requestedView user

        Nothing ->
            Error.view Nothing "No user details received"


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
                            Element.map HomeMsg <| Home.view homeModel

                        ViewingDashboard ->
                            handleAuthenticatedView model Dashboard.view

                        ViewingAccount accountModel ->
                            handleAuthenticatedView model <|
                                Element.map AccountMsg
                                    << Account.view accountModel

                        ViewingSignOut ->
                            SignOut.view

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
            , user = user
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
        [ Sub.map HomeMsg Home.subscriptions
        , User.userReceived (UserReceived << decodeValue User.decode)
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

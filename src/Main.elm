module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Element exposing (..)
import Page.Dashboard as Dashboard
import Page.DiscoveryForm as DiscoveryForm
import Page.Error as Error
import Page.FetchingUser as FetchingUser
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
    | FetchingUser FetchingUser.Model
    | ViewingDashboard Dashboard.Model
    | ViewingDiscoveryForm
    | ViewingErrorPage



-- UPDATE


type Msg
    = UrlChanged Url
    | UrlRequested Browser.UrlRequest
    | FetchingUserMsg FetchingUser.Msg


fetchUser : Model -> ( Model, Cmd Msg )
fetchUser model =
    let
        ( fetchingUserModel, fetchingUserCmd ) =
            FetchingUser.init
    in
    ( { model
        | state = FetchingUser fetchingUserModel
      }
    , Cmd.map FetchingUserMsg fetchingUserCmd
    )


handleUrlChange : Url -> Model -> ( Model, Cmd Msg )
handleUrlChange url model =
    case Route.parseRoute url of
        Error ->
            ( { model | state = ViewingErrorPage }, Cmd.none )

        Initial ->
            fetchUser model

        Route.FetchingUser ->
            fetchUser model

        Dashboard ->
            case model.user of
                Just user ->
                    ( { model
                        | state = ViewingDashboard <| Dashboard.init user
                      }
                    , Cmd.none
                    )

                Nothing ->
                    fetchUser model

        DiscoveryForm ->
            ( { model | state = ViewingDiscoveryForm }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            handleUrlChange url model

        FetchingUserMsg fetchingUserMsg ->
            let
                -- TODO: Refactor here so that we don't need let/in?
                ( fetchingUserModel, fetchingUserCmd, maybeUser ) =
                    FetchingUser.update model.navKey fetchingUserMsg
            in
            ( { model
                | state = FetchingUser fetchingUserModel
                , user = maybeUser
              }
            , Cmd.map FetchingUserMsg fetchingUserCmd
            )

        _ ->
            ( model, Cmd.none )



-- VIEW


loadingView : Element msg
loadingView =
    text "Loading..."


view : Model -> Browser.Document Msg
view model =
    { title = "POC"
    , body =
        [ layout [] <|
            case model.state of
                Loading ->
                    loadingView

                FetchingUser fetchingUserModel ->
                    FetchingUser.view fetchingUserModel

                ViewingDashboard dashboardModel ->
                    Dashboard.view dashboardModel

                ViewingDiscoveryForm ->
                    DiscoveryForm.view

                ViewingErrorPage ->
                    Error.view
        ]
    }



-- INIT


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    let
        startingModel =
            { navKey = navKey
            , state = Loading
            , user = Nothing
            }

        ( initialModel, initialCmd ) =
            handleUrlChange url startingModel
    in
    ( initialModel
    , initialCmd
    )


type alias Flags =
    ()


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.map FetchingUserMsg FetchingUser.subscriptions


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

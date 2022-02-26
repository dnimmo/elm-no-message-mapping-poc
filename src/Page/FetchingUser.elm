module Page.FetchingUser exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation exposing (Key)
import Element exposing (..)
import Route
import User exposing (User)



-- MODEL


type Model
    = Loading
    | Complete



-- UPDATE


type Msg
    = UserReceived String -- TODO: Make this a Result for a better demonstration


update : Key -> Msg -> ( Model, Cmd msg, Maybe User )
update key msg =
    case msg of
        UserReceived user ->
            ( Complete, Route.replaceUrl key <| Route.Dashboard, Just user )



-- VIEW


view : Model -> Element msg
view model =
    case model of
        Loading ->
            text "Loading..."

        Complete ->
            text "Redirecting..."



-- INIT


init : ( Model, Cmd Msg )
init =
    ( Loading
    , User.fetchUser True
    )


subscriptions : Sub Msg
subscriptions =
    User.userReceived UserReceived

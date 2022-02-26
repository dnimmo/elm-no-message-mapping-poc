module Page.FetchingUser exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation exposing (Key)
import Element exposing (..)
import Route
import User



-- MODEL


type Model
    = Loading
    | Complete



-- UPDATE


type Msg
    = UserReceived String -- TODO: Make this a result for a better demonstration


update : Key -> Msg -> ( Model, Cmd msg )
update key msg =
    case msg of
        UserReceived str ->
            ( Complete, Route.replaceUrl key Route.Dashboard )



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

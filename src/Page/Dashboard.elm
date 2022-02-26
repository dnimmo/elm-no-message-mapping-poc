module Page.Dashboard exposing (Model, Msg, init, update, view)

import Element exposing (..)
import User exposing (User)



-- MODEL


type Model
    = ViewingDashboard User
    | Error



-- UPDATE


type Msg
    = SignOut


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- VIEW


view : Model -> Element msg
view model =
    case model of
        ViewingDashboard user ->
            text <| "Welcome " ++ user ++ "!"

        Error ->
            text "Hmm, not sure you're allowed 'round these parts."



-- INIT


init : User -> Model
init user =
    ViewingDashboard user

module Page.Dashboard exposing
    ( Model
    , init
    , view
    )

import Components.Layout as Layout
import Element exposing (..)
import Route
import User exposing (User)



-- MODEL


type Model
    = Model User



-- VIEW


view : Model -> Element msg
view (Model user) =
    column
        [ spacing 20
        , width fill
        ]
        [ Layout.pageHeader
            { currentRoute = Route.Dashboard
            , parentRoute = Nothing
            }
        , text <| "Welcome " ++ user.name ++ "!"
        ]



-- INIT


init : User -> Model
init user =
    Model user

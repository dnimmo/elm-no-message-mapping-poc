module Page.Dashboard exposing (view)

import Components.Layout as Layout
import Element exposing (..)
import Route
import User exposing (User)


view : User -> Element msg
view user =
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

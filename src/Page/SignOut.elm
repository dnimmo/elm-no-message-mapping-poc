module Page.SignOut exposing (..)

import Components.Layout as Layout
import Element exposing (..)
import Route


view : Element msg
view =
    Layout.pageHeader
        { currentRoute = Route.SignOut
        , parentRoute = Just Route.Home
        }

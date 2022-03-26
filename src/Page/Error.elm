module Page.Error exposing (view)

import Element exposing (..)
import Route
import User



-- VIEW


view : User.Model -> String -> Element msg
view userModel str =
    column [ spacing 20 ]
        [ text <| "Something has gone wrong: " ++ str
        , Route.link
            { route =
                if User.isLoggedIn userModel then
                    Route.Dashboard

                else
                    Route.Home
            , labelText = "< Go back"
            }
        ]

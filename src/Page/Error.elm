module Page.Error exposing (view)

import Components.Navigation as Nav
import Element exposing (..)
import Route
import User exposing (User)



-- VIEW


view : Maybe User -> String -> Element msg
view maybeUser str =
    column [ spacing 20 ]
        [ text <| "Something has gone wrong: " ++ str
        , Nav.link
            { url =
                case maybeUser of
                    Just _ ->
                        Route.toString Route.Dashboard

                    Nothing ->
                        Route.toString Route.Home
            , labelText = "< Go back"
            }
        ]

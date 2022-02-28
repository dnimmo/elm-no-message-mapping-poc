module Page.Error exposing (view)

import Element exposing (..)
import Route
import User exposing (User)



-- VIEW


view : Maybe User -> String -> Element msg
view maybeUser str =
    column [ spacing 20 ]
        [ text <| "Something has gone wrong: " ++ str
        , Route.link
            { route =
                case maybeUser of
                    Just _ ->
                        Route.Dashboard

                    Nothing ->
                        Route.Home
            , labelText = "< Go back"
            }
        ]

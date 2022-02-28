module Components.Layout exposing (global, header, page, pageHeader)

import Components.Colours as Colours
import Components.Navigation as Nav
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Html exposing (Html)
import Route exposing (Route)
import User exposing (User)


global : Element msg -> Html msg
global =
    layout
        [ width fill
        , height fill
        , Background.color Colours.lightGrey
        ]


header : Maybe User -> Element msg
header maybeUser =
    el
        [ padding 20
        , width fill
        , Background.color Colours.orangeRed
        , Border.widthEach
            { top = 0
            , right = 0
            , left = 0
            , bottom = 2
            }
        ]
    <|
        case maybeUser of
            Just user ->
                authenticatedHeader user

            Nothing ->
                unauthenticatedHeader


siteTitle : Maybe User -> Element msg
siteTitle maybeUser =
    el [ width fill ] <|
        el [ centerX ] <|
            Nav.link
                { labelText = "Architecture POC"
                , url =
                    Route.toString <|
                        case maybeUser of
                            Just _ ->
                                Route.Dashboard

                            Nothing ->
                                Route.Home
                }


unauthenticatedHeader : Element msg
unauthenticatedHeader =
    row [ width fill ] [ siteTitle Nothing ]


authenticatedHeader : User -> Element msg
authenticatedHeader user =
    row [ width fill ]
        [ el [ width fill ] <|
            el [ width fill ] <|
                text <|
                    "Logged in as: "
                        ++ user.name
        , siteTitle <| Just user
        , column
            [ width fill
            , spacing 20
            ]
            [ el [ alignRight ] <|
                Nav.link
                    { labelText = "My account"
                    , url = Route.toString Route.Account
                    }
            , el [ alignRight ] <|
                Nav.link
                    { labelText = "Sign out"
                    , url = Route.toString Route.SignOut
                    }
            ]
        ]


page : Element msg -> Element msg
page =
    el
        [ padding 20
        , width fill
        , height fill
        ]


pageHeader : { currentRoute : Route, parentRoute : Maybe Route } -> Element msg
pageHeader { currentRoute, parentRoute } =
    row [ width fill ]
        [ el [ width fill ] <|
            case parentRoute of
                Just route ->
                    Nav.link
                        { labelText = "< " ++ Route.pageTitle route
                        , url = Route.toString route
                        }

                Nothing ->
                    none
        , el [ width fill ] <|
            el [ centerX ] <|
                text <|
                    Route.pageTitle currentRoute
        , el [ width fill ] none
        ]

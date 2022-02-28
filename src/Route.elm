module Route exposing
    ( Route(..)
    , link
    , pageTitle
    , parseRoute
    , parser
    , renderRoute
    , replaceUrl
    , toString
    )

import Browser.Navigation as Nav
import Element exposing (Element, text)
import Element.Border as Border
import Url exposing (Url)
import Url.Builder exposing (absolute)
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, top)


type Route
    = Home
    | Dashboard
    | Account
    | SignOut
    | Error


homeString : String
homeString =
    ""


dashboardString : String
dashboardString =
    "dashboard"


accountString : String
accountString =
    "account"


signOutString : String
signOutString =
    "sign-out"


errorString : String
errorString =
    "error"


parser : Parser (Route -> Route) Route
parser =
    oneOf
        [ map Home top
        , map Dashboard <| s dashboardString
        , map Account <| s accountString
        , map SignOut <| s signOutString
        , map Error <| s errorString
        ]


renderRoute : Route -> String
renderRoute route =
    case route of
        Home ->
            absolute [ homeString ] []

        Dashboard ->
            absolute [ dashboardString ] []

        Account ->
            absolute [ accountString ] []

        SignOut ->
            absolute [ signOutString ] []

        Error ->
            absolute [ errorString ] []


parseRoute : Url -> Route
parseRoute url =
    Maybe.withDefault Error <| parse parser url


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key <| renderRoute route


toString : Route -> String
toString route =
    "/"
        ++ (case route of
                Home ->
                    homeString

                Dashboard ->
                    dashboardString

                Account ->
                    accountString

                SignOut ->
                    signOutString

                Error ->
                    errorString
           )


pageTitle : Route -> String
pageTitle route =
    case route of
        Home ->
            "Sign in"

        Dashboard ->
            "Dashboard"

        Account ->
            "My account"

        SignOut ->
            "Signed out successfully"

        Error ->
            "Error"


link : { route : Route, labelText : String } -> Element msg
link { route, labelText } =
    Element.link
        [ Border.widthEach
            { top = 0
            , left = 0
            , right = 0
            , bottom = 1
            }
        ]
        { url = toString route, label = text labelText }

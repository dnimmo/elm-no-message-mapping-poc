module Route exposing
    ( Route(..)
    , pageTitle
    , parseRoute
    , parser
    , renderRoute
    , replaceUrl
    , toString
    )

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Builder exposing (absolute)
import Url.Parser exposing ((</>), (<?>), Parser, map, oneOf, parse, s, top)


type Route
    = Home
    | Dashboard
    | Account
    | SignOut
    | Error


parser : Parser (Route -> Route) Route
parser =
    oneOf
        [ map Home top
        , map Dashboard <| s "dashboard"
        , map Account <| s "account"
        , map SignOut <| s "sign-out"
        , map Error <| s "error"
        ]


renderRoute : Route -> String
renderRoute route =
    case route of
        Home ->
            absolute [ "" ] []

        Dashboard ->
            absolute [ "dashboard" ] []

        Account ->
            absolute [ "account" ] []

        SignOut ->
            absolute [ "sign-out" ] []

        Error ->
            absolute [ "error" ] []


parseRoute : Url -> Route
parseRoute url =
    Maybe.withDefault Error <| parse parser url


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key <| renderRoute route


toString : Route -> String
toString route =
    case route of
        Home ->
            "/"

        Dashboard ->
            "/dashboard"

        Account ->
            "/account"

        SignOut ->
            "/sign-out"

        Error ->
            "/error"


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

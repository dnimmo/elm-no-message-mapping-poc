module Route exposing (Route(..), parseRoute, parser, renderRoute, replaceUrl)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Builder exposing (absolute)
import Url.Parser exposing ((</>), (<?>), Parser, map, oneOf, parse, s, top)
import User exposing (User)


type Route
    = Initial
    | FetchingUser
    | Dashboard
    | DiscoveryForm
    | Error


parser : Parser (Route -> Route) Route
parser =
    oneOf
        [ map Initial top
        , map FetchingUser <| s "fetching-user"
        , map Dashboard <| s "dashboard"
        , map DiscoveryForm <| s "discovery"
        , map Error <| s "error"
        ]


renderRoute : Route -> String
renderRoute route =
    case route of
        Initial ->
            absolute [ "" ] []

        FetchingUser ->
            absolute [ "fetching-user" ] []

        Dashboard ->
            absolute [ "dashboard" ] []

        DiscoveryForm ->
            absolute [ "discovery" ] []

        Error ->
            absolute [ "error" ] []


parseRoute : Url -> Route
parseRoute url =
    Maybe.withDefault Error <| parse parser url


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key <| renderRoute route

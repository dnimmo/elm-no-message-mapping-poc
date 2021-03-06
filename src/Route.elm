module Route exposing
    ( Route(..)
    , link
    , pageTitle
    , parseRoute
    , parser
    , pushUrl
    , renderRoute
    , toString
    )

import Browser.Navigation as Nav
import Element exposing (Element, text)
import Element.Border as Border
import Url exposing (Url)
import Url.Builder as Builder exposing (absolute)
import Url.Parser as Parser exposing ((<?>), Parser, map, oneOf, parse, s, top)
import Url.Parser.Query as Query


type Route
    = Home
    | Dashboard
    | Account
    | SignOut
    | Error (Maybe String)


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
        , map Error <| s errorString <?> Query.string "message"
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

        Error errorStr ->
            absolute [ errorString ]
                [ Builder.string "message" <|
                    Maybe.withDefault "No message received" errorStr
                ]


parseRoute : Url -> Route
parseRoute url =
    Maybe.withDefault (Error <| Just "Route not found") <| parse parser url


pushUrl : Nav.Key -> Route -> Cmd msg
pushUrl key route =
    Nav.pushUrl key <| renderRoute route


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

                Error _ ->
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

        Error _ ->
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

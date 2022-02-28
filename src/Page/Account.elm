module Page.Account exposing (Msg, State, init, update, view)

import Components.Input as Input
import Components.Layout as Layout
import Element exposing (..)
import Route
import User exposing (User)



-- STATE


type State
    = ViewingAccount
    | EditingUsername String
    | Loading String
    | Error String



-- UPDATE


type Msg
    = StartEditingUsername
    | ViewAccount
    | UpdateUsername String
    | AttemptToSaveUsername String


update : Msg -> ( State, Cmd msg )
update msg =
    case msg of
        StartEditingUsername ->
            ( EditingUsername "", Cmd.none )

        ViewAccount ->
            ( ViewingAccount, Cmd.none )

        UpdateUsername str ->
            ( EditingUsername str, Cmd.none )

        AttemptToSaveUsername str ->
            ( Loading str, User.saveUsername str )



-- VIEW


accountView : Element Msg
accountView =
    row
        [ spacing 20
        , width fill
        ]
        [ Input.positiveButton "Change username" StartEditingUsername
        ]


editingUsernameView : User -> String -> Element Msg
editingUsernameView user newUsername =
    column
        [ spacing 20
        , width fill
        ]
        [ text <| "Current username: " ++ user.name
        , Input.textField UpdateUsername { value = newUsername, labelText = "Enter your new name" }
        , row
            [ width fill
            , spacing 20
            ]
            [ el [ width fill ] <| Input.negativeButton "Cancel" ViewAccount
            , el [ width fill ] <|
                if not <| String.isEmpty newUsername then
                    Input.positiveButton "Save" <| AttemptToSaveUsername newUsername

                else
                    none
            ]
        ]


errorView : String -> Element Msg
errorView str =
    column [ spacing 20 ]
        [ text str
        , Input.positiveButton "Try again" ViewAccount
        ]


view : State -> User -> Element Msg
view state user =
    column
        [ spacing 20
        , width fill
        , height fill
        ]
        [ Layout.pageHeader
            { currentRoute = Route.Account
            , parentRoute = Just Route.Dashboard
            }
        , el
            [ width fill
            , centerX
            , centerY
            ]
          <|
            case state of
                ViewingAccount ->
                    accountView

                EditingUsername str ->
                    editingUsernameView user str

                Loading _ ->
                    text "Loading..."

                Error str ->
                    errorView str
        ]



-- INIT


init : State
init =
    ViewingAccount

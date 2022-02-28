module Page.Account exposing (State, Msg, init, subscriptions, update, view)

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
    | ReceiveUsernameChangeResponse Bool


update : User -> State -> Msg -> ( State, Cmd msg, Maybe User )
update user state msg =
    case msg of
        StartEditingUsername ->
            ( EditingUsername "", Cmd.none, Nothing )

        ViewAccount ->
            ( ViewingAccount, Cmd.none, Nothing )

        UpdateUsername str ->
            ( EditingUsername str, Cmd.none, Nothing )

        AttemptToSaveUsername str ->
            ( Loading str, User.saveUsername str, Nothing )

        ReceiveUsernameChangeResponse True ->
            case state of
                Loading str ->
                    ( ViewingAccount, Cmd.none, Just <| User.updateName str user )

                _ ->
                    ( Error "Attempted to handle username change outside of the Loading state", Cmd.none, Nothing )

        ReceiveUsernameChangeResponse False ->
            ( Error "Something went wrong whilst attempting to change your username", Cmd.none, Nothing )



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


subscriptions : Sub Msg
subscriptions =
    User.nameChanged ReceiveUsernameChangeResponse

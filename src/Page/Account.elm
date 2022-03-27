module Page.Account exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Components.Input as Input
import Components.Layout as Layout
import Element exposing (..)
import Json.Decode as Decode
import Route
import User exposing (User)



-- MODEL


type Model
    = Model User State


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
    | UserUpdated (Result Decode.Error User)


handleStartEditingUsername : Model -> Model
handleStartEditingUsername (Model user state) =
    case state of
        ViewingAccount ->
            Model user <| EditingUsername ""

        _ ->
            Model user <| Error "Attempted to start editing username outside of ViewingAccount"


handleViewAccount : Model -> Model
handleViewAccount (Model user state) =
    case state of
        EditingUsername _ ->
            Model user ViewingAccount

        _ ->
            Model user <| Error "Attempted to view account outside of EditingUsername"


handleUpdateUsername : Model -> String -> Model
handleUpdateUsername (Model user state) str =
    case state of
        EditingUsername _ ->
            Model user <| EditingUsername str

        _ ->
            Model user <| Error "Attempted to update username outside of EditingUsername"


handleAttemptToSaveUsername : Model -> String -> ( Model, Cmd Msg )
handleAttemptToSaveUsername (Model user state) str =
    case state of
        EditingUsername _ ->
            ( Model user <| Loading str
            , User.saveUsername str
            )

        _ ->
            ( Model user <| Error "Attempted to save username outside of EditingUsername"
            , Cmd.none
            )


handleUserUpdated : Model -> Result Decode.Error User -> Model
handleUserUpdated (Model user state) result =
    case state of
        Loading _ ->
            case result of
                Ok _ ->
                    Model user ViewingAccount

                Err err ->
                    Model user <|
                        Error <|
                            Decode.errorToString err

        _ ->
            Model user <|
                Error "Attempted to handle user response outside of Loading"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartEditingUsername ->
            ( handleStartEditingUsername model
            , Cmd.none
            )

        ViewAccount ->
            ( handleViewAccount model
            , Cmd.none
            )

        UpdateUsername str ->
            ( handleUpdateUsername model str
            , Cmd.none
            )

        AttemptToSaveUsername str ->
            handleAttemptToSaveUsername model str

        UserUpdated result ->
            ( handleUserUpdated model result
            , Cmd.none
            )



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


view : Model -> Element Msg
view (Model user state) =
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


init : User -> Model
init user =
    Model user ViewingAccount


subscriptions : Sub Msg
subscriptions =
    User.storedUserUpdated <|
        UserUpdated
            << Decode.decodeValue User.decode

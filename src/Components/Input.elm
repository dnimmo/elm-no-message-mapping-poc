module Components.Input exposing (currentPassword, email, negativeButton, positiveButton, textField)

import Components.Colours as Colours
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input



-- BUTTONS


type Button
    = PositiveAction
    | NegativeAction


buttonStyles : Button -> List (Attribute msg)
buttonStyles buttonType =
    [ Background.color <|
        case buttonType of
            PositiveAction ->
                Colours.positive

            NegativeAction ->
                Colours.negative
    , paddingXY 20 10
    , Border.color Colours.black
    , Border.width 1
    , Border.rounded 10
    , width fill
    ]


button : Button -> String -> msg -> Element msg
button buttonType labelText onPress =
    Input.button (buttonStyles buttonType)
        { label = el [ width fill ] <| el [ centerX ] <| text labelText
        , onPress = Just onPress
        }


positiveButton : String -> msg -> Element msg
positiveButton =
    button PositiveAction


negativeButton : String -> msg -> Element msg
negativeButton =
    button NegativeAction



-- FIELDS


standardLabel : String -> Input.Label msg
standardLabel str =
    Input.labelAbove [] <| text str


type alias TextInputFieldParams =
    { value : String
    , labelText : String
    }


email : (String -> msg) -> TextInputFieldParams -> Element msg
email onChangeMsg { value, labelText } =
    Input.email []
        { onChange = onChangeMsg
        , text = value
        , placeholder = Nothing
        , label = standardLabel labelText
        }


currentPassword : (String -> msg) -> { value : String, labelText : String, show : Bool } -> Element msg
currentPassword onChangeMsg { value, labelText, show } =
    Input.currentPassword []
        { onChange = onChangeMsg
        , text = value
        , placeholder = Nothing
        , label = standardLabel labelText
        , show = show
        }


textField : (String -> msg) -> TextInputFieldParams -> Element msg
textField onChangeMsg { value, labelText } =
    Input.text []
        { onChange = onChangeMsg
        , text = value
        , placeholder = Nothing
        , label = standardLabel labelText
        }

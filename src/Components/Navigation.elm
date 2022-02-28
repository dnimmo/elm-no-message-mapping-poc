module Components.Navigation exposing (..)

import Element exposing (..)


link : { url : String, labelText : String } -> Element msg
link { url, labelText } =
    Element.link [] { url = url, label = text labelText }

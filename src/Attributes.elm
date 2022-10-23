module Attributes exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (attribute)


ifAttr : Bool -> Attribute msg -> Attribute msg
ifAttr condition attr =
    if condition then
        attr

    else
        Html.Attributes.classList []


inputmode : String -> Attribute msg
inputmode value =
    attribute "inputmode" value


ariaHidden : Bool -> Attribute msg
ariaHidden value =
    attribute "aria-hidden"
        (if value then
            "true"

         else
            "false"
        )

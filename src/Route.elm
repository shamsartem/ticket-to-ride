module Route exposing (Route(..), fromUrl, href, pushUrl, replaceUrl)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf)



-- ROUTING


type Route
    = Index


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ Parser.map Index Parser.top
        ]



-- public helpers


href : Route -> Attribute msg
href targetroute =
    Attr.href (routeToString targetroute)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


pushUrl : Nav.Key -> Route -> Cmd msg
pushUrl key route =
    Nav.pushUrl key (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse routeParser url



-- internal


routeToString : Route -> String
routeToString page =
    "/" ++ String.join "/" (routeToPath page)


routeToPath : Route -> List String
routeToPath page =
    case page of
        Index ->
            []

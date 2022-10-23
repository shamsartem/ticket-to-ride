module Store exposing
    ( Store
    , windowWidthExtraLarge
    , windowWidthLarge
    , windowWidthSmall
    )

import Browser.Navigation as Nav
import Url exposing (Url)


type alias Store =
    { navKey : Nav.Key
    , isRefreshWindowVisible : Bool
    , isOfflineReadyWindowVisible : Bool
    , toasts : List String
    , windowWidth : Int
    , url : Url
    }



-- WINDOW WIDTH
-- please update media.css as well


windowWidthSmall : Int
windowWidthSmall =
    768


windowWidthLarge : Int
windowWidthLarge =
    992


windowWidthExtraLarge : Int
windowWidthExtraLarge =
    1200

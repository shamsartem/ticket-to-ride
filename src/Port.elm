port module Port exposing
    ( Message
    , SendMessage(..)
    , gotMessage
    , send
    )

import Json.Encode


type alias Message =
    { tag : String, payload : Json.Encode.Value }


port sendMessage : Message -> Cmd msg


port gotMessage : (Message -> msg) -> Sub msg


type SendMessage
    = RefreshApp


send : SendMessage -> Cmd a
send msg =
    (case msg of
        RefreshApp ->
            { tag = "RefreshAppClicked", payload = Json.Encode.null }
    )
        |> sendMessage

module Main exposing (Model, main)

import Browser exposing (Document)
import Browser.Events exposing (onResize)
import Browser.Navigation as Nav
import Html exposing (..)
import Json.Decode
import Page.Index as Index
import Page.NotFound as NotFound
import Port
import Process
import Route exposing (Route(..))
import Store exposing (Store)
import Task
import Url exposing (Url)
import View.Confirm as Confirm
import View.Toasts as Toasts


type alias Flags =
    { windowWidth : Int
    }



-- MODEL


type Model
    = NotFound Store
    | Index Index.Model


initialModel : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
initialModel { windowWidth } url key =
    let
        store : Store
        store =
            { navKey = key
            , url = url
            , windowWidth = windowWidth
            , isRefreshWindowVisible = False
            , isOfflineReadyWindowVisible = False
            , toasts = []
            }
    in
    case Route.fromUrl url of
        Nothing ->
            ( NotFound store, Cmd.none )

        Just _ ->
            let
                ( indexModel, indexCommand ) =
                    Index.init store
            in
            ( Index indexModel
            , Cmd.map GotIndexMsg indexCommand
            )


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    initialModel flags url key


getTitle : Model -> String
getTitle model =
    let
        getFullTitle title =
            title ++ " - Ticket to Ride"
    in
    case model of
        Index _ ->
            getFullTitle "Calculator"

        NotFound _ ->
            getFullTitle "Not found"


view : Model -> Document Msg
view model =
    let
        { isOfflineReadyWindowVisible, isRefreshWindowVisible, toasts } =
            getStore model

        viewPage toMsg content =
            { title = getTitle model
            , body =
                [ Html.map toMsg content
                , if isOfflineReadyWindowVisible then
                    Confirm.view
                        { title = "App is ready to work offline"
                        , maybeBody = Nothing
                        , cancelButton =
                            { title = "Ok"
                            , handleClick = OkOfflineReadyClicked
                            }
                        , okButton = Nothing
                        }

                  else
                    text ""
                , if isRefreshWindowVisible then
                    Confirm.view
                        { title = "There is new app version. Update?"
                        , maybeBody = Nothing
                        , cancelButton =
                            { title = "No"
                            , handleClick = CancelRefreshClicked
                            }
                        , okButton =
                            Just
                                { title = "Yes"
                                , handleClick = RefreshClicked
                                }
                        }

                  else
                    text ""
                , if List.length toasts /= 0 then
                    Toasts.view toasts

                  else
                    text ""
                ]
            }
    in
    case model of
        NotFound _ ->
            { title = getTitle model
            , body = [ NotFound.view ]
            }

        Index indexModel ->
            viewPage GotIndexMsg (Index.view indexModel)


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url
    | GotIndexMsg Index.Msg
    | GotNewWindowWidth Int
    | RecievedMessage Port.Message
    | OkOfflineReadyClicked
    | RefreshClicked
    | CancelRefreshClicked
    | RemoveToast


getStore : Model -> Store
getStore model =
    case model of
        NotFound store ->
            store

        Index indexModel ->
            Index.getStore indexModel


setStore : Store -> Model -> Model
setStore store model =
    case model of
        NotFound _ ->
            NotFound store

        Index indexModel ->
            Index (Index.setStore store indexModel)


changeRouteTo : Maybe Route -> Store -> ( Model, Cmd Msg )
changeRouteTo maybeRoute store =
    case maybeRoute of
        Nothing ->
            ( NotFound store, Cmd.none )

        Just Route.Index ->
            Index.init
                store
                |> updatePageWith Index GotIndexMsg


updatePageWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updatePageWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    let
        store =
            model |> getStore
    in
    case ( message, model ) of
        ( GotNewWindowWidth width, _ ) ->
            ( setStore { store | windowWidth = width } model, Cmd.none )

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl store.navKey (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( ChangedUrl url, _ ) ->
            changeRouteTo
                (Route.fromUrl url)
                { store | url = url }

        ( GotIndexMsg subMsg, Index signInModel ) ->
            Index.update subMsg signInModel
                |> updatePageWith Index GotIndexMsg

        ( RecievedMessage { tag, payload }, _ ) ->
            case tag of
                "NeedRefresh" ->
                    ( setStore
                        { store | isRefreshWindowVisible = True }
                        model
                    , Cmd.none
                    )

                "OfflineReady" ->
                    ( setStore
                        { store | isOfflineReadyWindowVisible = True }
                        model
                    , Cmd.none
                    )

                "Toast" ->
                    case
                        payload |> Json.Decode.decodeValue Json.Decode.string
                    of
                        Ok toast ->
                            ( setStore
                                { store | toasts = List.append store.toasts [ toast ] }
                                model
                            , Process.sleep 5000
                                |> Task.perform (\_ -> RemoveToast)
                            )

                        Err _ ->
                            -- js should always send string toast
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ( RemoveToast, _ ) ->
            ( setStore { store | toasts = List.drop 1 store.toasts } model, Cmd.none )

        ( OkOfflineReadyClicked, _ ) ->
            ( setStore
                { store | isOfflineReadyWindowVisible = False }
                model
            , Cmd.none
            )

        ( RefreshClicked, _ ) ->
            ( setStore
                { store | isRefreshWindowVisible = False }
                model
            , Port.send Port.RefreshApp
            )

        ( CancelRefreshClicked, _ ) ->
            ( setStore
                { store | isRefreshWindowVisible = False }
                model
            , Cmd.none
            )

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSubscriptions =
            case model of
                NotFound _ ->
                    Sub.none

                Index m ->
                    Sub.map GotIndexMsg (Index.subscriptions m)
    in
    Sub.batch
        [ pageSubscriptions
        , onResize (\w _ -> GotNewWindowWidth w)
        , Port.gotMessage RecievedMessage
        ]



-- MAIN


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }

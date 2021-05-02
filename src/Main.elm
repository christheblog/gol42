module Main exposing (main)

import Browser
import State.AppState exposing (AppState)
import Update.Msg exposing (Msg)
import Update.Logic exposing (update)
import View.AppView exposing (viewApp)


initState: () -> (AppState, Cmd Msg)
initState () = (State.AppState.empty, Cmd.none)

main = Browser.element {
    init = initState,
    view = viewApp,
    update = update,
    subscriptions = subscriptions
  }

subscriptions: AppState -> Sub Msg
subscriptions _ = Sub.none
module View.AppView exposing (viewApp)

import Element exposing (Element, column, fill, height, padding, spacing, width)
import Html exposing (Html)
import State.AppState exposing (AppState, Screen(..))
import Update.Msg exposing (Msg)
import View.NewGameScreen exposing (newGameScreen)
import View.TwoPlayersScreen exposing (twoPlayersScreen)
import View.WinnerScreen exposing (winnerScreen)


viewApp: AppState -> Html Msg
viewApp state = Element.layout [width fill, height fill]
    (column [ width fill, height fill, padding 5, spacing 10 ]
            [ displayCurrentScreen state ])

displayCurrentScreen: AppState -> Element Msg
displayCurrentScreen state = case state.screen |> Debug.log "Screen" of
    NewGameScreen -> newGameScreen state
    PlayScreen    -> twoPlayersScreen state
    WinnerScreen  -> winnerScreen state

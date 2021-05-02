module State.AppState exposing (..)

import GoL.TwoPlayers as TwoPlayers exposing (Difficulty(..), Game)
import State.NewGameWizard exposing (NewGameWizard, defaultGameWizard)


type Screen = NewGameScreen
    | PlayScreen
    | WinnerScreen

type alias AppState = {
    screen: Screen,
    newGame: NewGameWizard,
    twoPlayersGame: Game,
    playable: Bool
 }

empty: AppState
empty = {
    screen = NewGameScreen,
    newGame = defaultGameWizard,
    twoPlayersGame = TwoPlayers.init 11 11 Easy 1,
    playable = True
 }

newGame: AppState -> AppState
newGame state = let game = state.newGame in {state |
    twoPlayersGame = TwoPlayers.init game.width game.height game.difficulty game.tokens
 }



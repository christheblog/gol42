module Update.Msg exposing (..)


import GoL.Board exposing (Height, Position, Width)
import GoL.TwoPlayers exposing (Game, Player, Difficulty)
import State.AppState exposing (Screen)

type Msg =
    ChangeScreen Screen
    | CreateNewTwoPlayersGame
    | NewGameGridDimensions Width Height
    | NewGameTokenCount Int
    | NewGameDifficulty Difficulty
    | PutToken Player Position
    | Flash Int Game Game
    | NextTurn
    | CheckVictory
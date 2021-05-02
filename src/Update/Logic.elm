module Update.Logic exposing (update)

import GoL.TwoPlayers as TwoPlayersGame exposing (Player(..), Victory(..))
import Process
import State.AppState exposing (AppState, Screen(..), newGame)
import State.NewGameWizard exposing (updateGridDimensions, updateDifficulty, updateTokenCount)
import Task
import Update.Msg exposing (Msg(..))


update: Msg -> AppState -> (AppState, Cmd Msg)
update msg state = case msg of
    ChangeScreen screen       -> {state| screen = screen} |> nocmd
    CreateNewTwoPlayersGame   -> newGame state |> changeScreen PlayScreen
    -- New Game wizard
    NewGameGridDimensions w h -> {state|
        newGame = updateGridDimensions state.newGame w h}
        |> nocmd
    NewGameTokenCount count   -> {state|
        newGame = updateTokenCount state.newGame count}
        |> nocmd
    NewGameDifficulty level   -> {state|
        newGame = updateDifficulty state.newGame level}
        |> nocmd
    -- Playing
    PutToken _ position       -> {state|
        twoPlayersGame = state.twoPlayersGame |> TwoPlayersGame.playAt position  }
        |> (NextTurn |> asCommand |> cmd)
    NextTurn                  ->
        let newturn = state.twoPlayersGame.turn==Black && state.twoPlayersGame.remaining==0
            oldState = state
            newState = { state|
                twoPlayersGame = if newturn
                                 then TwoPlayersGame.next state.twoPlayersGame
                                 else TwoPlayersGame.nextPlayerTurn state.twoPlayersGame }
        in newState
        |> if newturn
           then (flash 6 oldState newState) |> cmd
           else nocmd
    Flash remaining old new   -> {state|
        playable       = remaining <= 0,
        twoPlayersGame = if remaining <= 0 then new
                         else if modBy 2 remaining == 0 then old
                         else new }
        |> if remaining <= 0 then checkVictory else cmd (delay 125 (Flash (remaining - 1) old new))
    CheckVictory             ->
        case (Debug.log "Winner" (TwoPlayersGame.winner state.twoPlayersGame)) of
        Draw          -> state |> changeScreen WinnerScreen
        Winner winner -> state |> changeScreen WinnerScreen
        NotFinished   -> state |> nocmd


{-- Helpers --}

nocmd: AppState -> (AppState, Cmd Msg)
nocmd state = (state, Cmd.none)

cmd: Cmd Msg -> AppState -> (AppState, Cmd Msg)
cmd command state = (state, command)

asCommand: Msg -> Cmd Msg
asCommand msg = msg
    |> Task.succeed
    |> Task.perform identity

-- Delay (in seconds) the sending of the given message
delay : Float -> msg -> Cmd msg
delay time msg =
  Process.sleep time
  |> Task.andThen (always <| Task.succeed msg)
  |> Task.perform identity

flash: Int -> AppState -> AppState -> Cmd Msg
flash n old new =  (Flash n old.twoPlayersGame new.twoPlayersGame)
    |> asCommand

changeScreen: Screen -> AppState -> (AppState, Cmd Msg)
changeScreen screen = (ChangeScreen screen) |> asCommand |> cmd

checkVictory: AppState -> (AppState, Cmd Msg)
checkVictory = CheckVictory |> asCommand |> cmd

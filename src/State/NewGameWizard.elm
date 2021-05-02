module State.NewGameWizard exposing (..)

import GoL.Board exposing (Height, Width)
import GoL.TwoPlayers exposing (Difficulty(..))



type alias NewGameWizard = {
    width: Width,
    height: Height,
    tokens: Int,
    difficulty: Difficulty
 }

defaultGameWizard: NewGameWizard
defaultGameWizard = {
    width      = 11,
    height     = 11,
    tokens     = 1,
    difficulty = Easy
 }

updateGridDimensions: NewGameWizard -> Width -> Height -> NewGameWizard
updateGridDimensions state w h = if w > 1 && h > 1
    then {state | width = w, height = h }
    else state

updateTokenCount: NewGameWizard -> Int -> NewGameWizard
updateTokenCount state count = if count >= 1
    then {state | tokens = count }
    else state

updateDifficulty: NewGameWizard -> Difficulty -> NewGameWizard
updateDifficulty state rules = {state | difficulty = rules }
module GoL.TwoPlayers exposing (
    Player(..)
    , Victory(..)
    ,Difficulty(..)
    ,Game
    , init
    , next
    , playAt
    , countFilled
    , countNeighboursForPlayer
    , nextPlayerTurn
    , winner)

import Array
import GoL.Board as Board exposing (Board, Cell(..), Height, Position, Width, allPositions, at, countNeighbours, isEmpty, isFilled, neighbours)
import GoL.BoardHelper as BoardHelper

type Player = Red | Black

type Victory = Winner Player
    | Draw
    | NotFinished

type Difficulty =
    Easy     -- Just spawn new cells
    | Normal -- Just kills cell
    | Hard   -- Full Game of life rules

type alias Rules =  Int -> Int -> Cell Player -> Cell Player

type alias Game = {
    board: Board Player,
    turn: Player,
    tokens: Int,
    remaining: Int,
    iteration: Int,
    difficulty: Difficulty
 }

init: Width -> Height -> Difficulty -> Int -> Game
init w h difficulty tokens =
    let board = Board.empty w h
                |> BoardHelper.lineOfCrosses (Filled Black) 2
                |> BoardHelper.lineOfCrosses (Filled Red) (h - 1)
    in {
        board     = board,
        turn      = Red,
        tokens    = tokens,
        remaining = tokens,
        iteration = 1,
        difficulty = difficulty
     }

next: Game -> Game
next game = {game|
    board = nextBoard (selectRules game.difficulty) game.board,
    turn = nextPlayer game.turn,
    remaining = game.tokens,
    iteration = game.iteration + 1
 }

nextPlayerTurn: Game -> Game
nextPlayerTurn game = if game.remaining > 0
    then game
    else {game|
        turn = nextPlayer game.turn,
        remaining = game.tokens
     }

playAt: Position -> Game -> Game
playAt pos game = {game|
    remaining = game.remaining - 1 |> max 0,
    board = Board.placeAt (Filled game.turn) pos game.board }

countFilled: Player -> Game -> Int
countFilled player game =
    let toNumber    = (\cell -> if cell==Filled player then 1 else 0)
        countForRow = (\r    -> (Array.toList r) |> List.map (toNumber) |> List.sum)
    in game.board.cells |> Array.map (countForRow) |> Array.toList |> List.sum

countNeighboursForPlayer: Position -> Player -> Board Player -> Int
countNeighboursForPlayer pos player board =
    neighbours pos board |> (List.filter (at board >> (\cell -> cell == Filled player))) |> List.length

-- Winner
winner: Game -> Victory
winner game = case game.difficulty of
    Easy   -> winnerEasy game
    Normal -> winnerNormal game
    Hard   -> winnerHard game

winnerEasy: Game -> Victory
winnerEasy game =
    let lessThan4      = (\pos -> (countNeighbours pos isFilled game.board) < 4)
        lessThan4Count = Board.allPositions game.board
            |> List.filter (isEmpty << Board.at game.board)
            |> List.filter (lessThan4)
            |> List.length
        canStillPlay   = lessThan4Count > 0
        redCount       = countFilled Red game
        blackCount     = countFilled Black game
    in if canStillPlay then NotFinished
       else if redCount==blackCount then Draw
       else if redCount > blackCount then Winner Red
       else Winner Black

winnerNormal: Game -> Victory
winnerNormal game =
    let redCount     = countFilled Red game
        blackCount   = countFilled Black game
    in if redCount == 0 && redCount==blackCount then Draw
       else if redCount == 0  then Winner Black
       else if blackCount == 0  then Winner Red
       else NotFinished

winnerHard: Game -> Victory
winnerHard game =
    let redCount     = countFilled Red game
        blackCount   = countFilled Black game
    in if redCount == 0 && redCount==blackCount then Draw
       else if redCount == 0  then Winner Black
       else if blackCount == 0  then Winner Red
       else NotFinished


{-- Helpers --}

nextPlayer: Player -> Player
nextPlayer player = case player of
    Red   -> Black
    Black -> Red

nextBoard: Rules -> Board Player -> Board Player
nextBoard rules board =
    let positions           = allPositions board
        redNeighbourCount   = (\position -> countNeighbours position ((==) (Filled Red)) board)
        blackNeighbourCount = (\position -> countNeighbours position ((==) (Filled Black))  board)
        accfn               = (\pos acc -> acc |> Board.placeAt (rules (redNeighbourCount pos) (blackNeighbourCount pos) (at board pos)) pos)
    in List.foldl (accfn) board positions


{-- Rules implementation --}

selectRules: Difficulty -> Rules
selectRules level = case level of
    Easy   -> justSpawnNewCells
    Normal -> justKillCells
    Hard   -> gameOfLifeRules

justSpawnNewCells: Int -> Int -> Cell Player -> Cell Player
justSpawnNewCells aliveRed aliveBlack cell = case (aliveRed, aliveBlack, cell) of
    (_, _, Filled player) -> Filled player
    (3, 0, Empty)         -> Filled Red
    (2, 1, Empty)         -> Filled Red
    (0, 3, Empty)         -> Filled Black
    (1, 2, Empty)         -> Filled Black
    _                     -> Empty

justKillCells: Int -> Int -> Cell Player -> Cell Player
justKillCells aliveRed aliveBlack cell = case (aliveRed, aliveBlack, cell) of
    (red, black, Filled player) -> let count = red + black in
                                   if count==2 || count==3 then (Filled player) else Empty
    _                           -> Empty

gameOfLifeRules: Int -> Int -> Cell Player -> Cell Player
gameOfLifeRules aliveRed aliveBlack cell = case (aliveRed, aliveBlack, cell) of
    (red, black, Filled player) -> let count = red + black in
                                   if count==2 || count==3 then (Filled player) else Empty
    (3, 0, Empty)               -> Filled Red
    (2, 1, Empty)               -> Filled Red
    (0, 3, Empty)               -> Filled Black
    (1, 2, Empty)               -> Filled Black
    _                           -> Empty

module GoL.ZeroPlayer exposing (Game, empty, next, seed)

import GoL.Board as Board exposing (Board, Cell(..), Height, Position, Width, allPositions, at, countNeighbours, isFilled, placeAt)


type alias Game = {
    board: Board (),
    turn: Int
 }

empty: Width -> Height -> Game
empty w h = {
    board = Board.empty w h,
    turn = 0
 }

seed: List Position -> Game -> Game
seed positions game =
    let initialized = List.foldl (\pos acc -> placeAt (Filled ()) pos acc) game.board positions
    in {game| board=initialized }

next: Game -> Game
next {board, turn } = {
    board= nextBoard board,
    turn= turn + 1
 }


{-- Helpers --}

nextBoard: Board () -> Board ()
nextBoard board =
    let positions      = allPositions board
        neighbourCount = (\position -> countNeighbours position (isFilled) board)
        accfn          =  (\pos acc -> acc |> placeAt (rules (neighbourCount pos) (at board pos)) pos)
    in List.foldl (accfn) board positions

rules: Int -> Cell () -> Cell ()
rules alive cell = case (alive, isFilled cell) of
    (count, True) -> if count==2 || count==3 then (Filled ()) else Empty
    (3, False)    -> Filled ()
    _             -> Empty

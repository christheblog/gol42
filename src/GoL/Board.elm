module GoL.Board exposing (
    Width
    , Height
    , Position
    , Cell(..)
    , Board
    , empty
    , clear
    , placeAt
    , at
    , neighbours
    , find
    , allPositions
    , countNeighbours
    , isFilled
    , isEmpty
 )

import Array exposing (Array)

type alias X = Int
type alias Y = Int
type alias Width = Int
type alias Height = Int

type alias Position = {
    x: X,
    y: Y
 }

type Cell a = Filled a | Empty

type alias Board a = {
    width: Width,
    height: Height,
    cells: Array (Array (Cell a)) -- list of lines
 }

empty: Width -> Height -> Board a
empty w h = {
    width = max 0 w,
    height = max 0 h,
    cells = Array.initialize h (\ _ -> Array.initialize w (\ _ -> Empty))
 }

clear: Position -> Board a -> Board a
clear pos board =
    let maybeCleared = setCellAt Empty (pos |> cyclePosition board) board in
    maybeCleared |> Maybe.withDefault board

placeAt: Cell a -> Position -> Board a -> Board a
placeAt cell pos board =
    let cycled = pos |> cyclePosition board
        maybePlaced = setCellAt cell cycled board
    in maybePlaced |> Maybe.withDefault board

at: Board a -> Position -> Cell a
at board pos =
    let cycled = cyclePosition board pos
        maybeCell = cellAt cycled board
    in maybeCell |> Maybe.withDefault Empty

neighbours: Position -> Board a -> List Position
neighbours pos board = board
    |> directNeighbours pos
    |> List.map (cyclePosition board)

find: (Position -> Bool) -> Board a -> List Position
find predicate board = allPositions board
    |> List.filter (predicate)

allPositions: Board a -> List Position
allPositions {width, height, cells } =
    let xs = List.range 1 width
        ys = List.range 1 height
    in ys |> List.concatMap (\y -> xs |> List.map (\x -> {x=x , y=y}))

countNeighbours: Position -> (Cell a -> Bool) -> Board a -> Int
countNeighbours pos predicate board =
    neighbours pos board |> (List.filter (at board >> predicate)) |> List.length

isFilled: Cell a -> Bool
isFilled c = case c of
    Filled _ -> True
    Empty    -> False

isEmpty: Cell a -> Bool
isEmpty c = case c of
    Filled _ -> False
    Empty    -> True

{-- Helpers --}

-- Make sure a given row is on the board, cycling if necessary
cycleRow: Board a -> Y -> Y
cycleRow board r = (modBy board.height (r - 1)) + 1

-- Make sure a given column is on the board, cycling if necessary
cycleCol: Board a -> X -> X
cycleCol board c = (modBy board.width (c - 1)) + 1

-- Make sure a given position remains on the board
cyclePosition: Board a -> Position -> Position
cyclePosition board {x, y} = { x = cycleCol board x, y = cycleRow board y}

-- indices start at 1
row: Y -> Board a -> Maybe (Array (Cell a))
row r board = Array.get (r - 1) board.cells

cellAt: Position -> Board a -> Maybe (Cell a)
cellAt {x,y} board = row y board
    |> Maybe.andThen (\r -> Array.get (x - 1) r)

setCellAt: Cell a -> Position -> Board a -> Maybe (Board a)
setCellAt cell {x, y} board =
    let r = row y board
        modified = r |> Maybe.map (Array.set (x - 1) cell)
    in modified
        |> Maybe.map (\ m -> Array.set (y - 1) m board.cells)
        |> Maybe.map (\cells -> {board| cells = cells })

directNeighbours: Position -> Board a -> List Position
directNeighbours {x , y} board = [
    {x = x - 1 , y = y - 1 },
    {x = x     , y = y - 1 },
    {x = x + 1 , y = y - 1 },
    {x = x - 1 , y = y },
    {x = x + 1 , y = y },
    {x = x - 1 , y = y + 1 },
    {x = x     , y = y + 1 },
    {x = x + 1 , y = y + 1 }
 ]




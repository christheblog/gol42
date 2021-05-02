module GoL.BoardHelper exposing (..)


import GoL.Board as Board exposing (Board, Cell, Position)

-- Draw a square from the to-left corner
square: Cell a -> Position -> Board a -> Board a
square cell {x,y} board = board
    |> Board.placeAt cell {x=x,   y=y }
    |> Board.placeAt cell {x=x+1, y=y }
    |> Board.placeAt cell {x=x,   y=y+1 }
    |> Board.placeAt cell {x=x+1, y=y+1 }

cross: Cell a -> Position -> Board a -> Board a
cross cell {x,y} board = board
    |> Board.placeAt cell {x= x,     y= y - 1 }
    |> Board.placeAt cell {x= x,     y= y + 1 }
    |> Board.placeAt cell {x= x - 1, y= y }
    |> Board.placeAt cell {x= x + 1, y= y }

lineOfCrosses: Cell a -> Int -> Board a -> Board a
lineOfCrosses cell y board = range 2 board.width 4
    |> List.foldl (\x acc -> cross cell {x=x,y=y} acc) board



range: Int -> Int -> Int -> List Int
range min max by = if min > max
    then []
    else min::range (min+by) max by

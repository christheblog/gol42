module View.TwoPlayersScreen exposing (twoPlayersScreen)

import Array
import Element exposing (Color, Element, alignLeft, alignRight, centerX, centerY, column, el, fill, height, padding, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import GoL.Board as Board exposing (Cell(..), Position, isEmpty, isFilled)
import GoL.TwoPlayers exposing (Difficulty(..), Player(..), countFilled, countNeighboursForPlayer)
import State.AppState exposing (AppState)
import Update.Msg exposing (Msg(..))
import View.Icons as Icons
import View.Theme as Theme


twoPlayersScreen: AppState -> Element Msg
twoPlayersScreen state = column [
        width fill
        , height fill
        , centerX
        , spacing 20
        , padding 5 ]
    [ renderScores state
     , renderTokenCount state
     , renderBoard state]

renderTokenCount: AppState -> Element Msg
renderTokenCount state =
    if(state.twoPlayersGame.tokens <= 1) then Element.none
    else row [width fill, spacing 5]
        [(state.twoPlayersGame.remaining |> String.fromInt) ++ " token(s) remaining" |> text]

renderScores: AppState -> Element Msg
renderScores state = row [width fill] [
    row [width fill, spacing 5, padding 2] [
        "Player Red: "
        |> text
        |> el (if state.twoPlayersGame.turn==Red
               then [Font.color Theme.white, Background.color Theme.darkRed, alignLeft]
               else [Font.color Theme.darkRed, alignLeft]) ,
        countFilled Red state.twoPlayersGame |> String.fromInt |> text |> el [Font.color Theme.darkRed, Font.bold, alignLeft ]
    ,row [width fill, spacing 5, padding 2] [
        "Player Black: "
        |> text
        |> el (if state.twoPlayersGame.turn==Black
            then [Font.color Theme.white, Background.color Theme.black, alignRight]
            else [Font.color Theme.black, alignRight]) ,
        countFilled Black state.twoPlayersGame |> String.fromInt |> text |> el [Font.color Theme.black, Font.bold, alignRight ]
    ]
 ]]

renderBoard: AppState -> Element Msg
renderBoard state = column [
        centerX
        , centerY
        , width fill
        , height fill
        , padding 10
        , Border.width 5
        , Border.color (colorForPlayer state.twoPlayersGame.turn)]
    (state.twoPlayersGame.board.cells
        |> Array.indexedMap (\rindex r -> row [width fill, height fill]
            (r |> Array.indexedMap (\cindex c -> renderCell state {x=cindex+1, y=rindex+1} c) |> Array.toList))
        |> Array.toList)

renderCell: AppState -> Position -> Cell Player -> Element Msg
renderCell state = case state.twoPlayersGame.difficulty of
    Easy -> renderCellEasy state
    Normal -> renderCellNormal state
    Hard -> renderCellHard state


-- Easy mode: no cell dies, cells spawn
renderCellEasy: AppState -> Position -> Cell Player -> Element Msg
renderCellEasy state pos cell =
    let redNeighbours = state.twoPlayersGame.board |> countNeighboursForPlayer pos Red
        blackNeighbours = state.twoPlayersGame.board |> countNeighboursForPlayer pos Black
        neighbours = redNeighbours + blackNeighbours
        eltFontColor = if (isEmpty cell) && neighbours==3 && redNeighbours > blackNeighbours then Theme.darkRed
                       else if (isEmpty cell) && neighbours==3 && blackNeighbours > redNeighbours then Theme.black
                       else Theme.white
        color = case cell of
                Filled Red   -> Theme.darkRed
                Filled Black -> Theme.black
                Empty        -> if neighbours==3 then Theme.darkGrey else Theme.grey
        cellElt = case cell of
                  Filled _   -> (neighbours |> String.fromInt) |> text
                  Empty      -> if neighbours==3
                                then Icons.alive Icons.normal
                                else (neighbours |> String.fromInt) |> text
    in Input.button [width fill
        , height fill
        , Background.color color
        , Border.color Theme.white
        , Border.rounded 6
        , Border.width 3]
        { onPress = if isFilled cell || state.twoPlayersGame.remaining==0
                    then Nothing
                    else (PutToken state.twoPlayersGame.turn pos) |> Just,
          label = cellElt |> el [centerX, centerY, Font.color eltFontColor] }

-- Normal mode: cells die, no cell spanws
renderCellNormal: AppState -> Position -> Cell Player -> Element Msg
renderCellNormal state pos cell =
    let neighbours = state.twoPlayersGame.board |> Board.countNeighbours pos isFilled
        color = case cell of
                Filled Red   -> Theme.darkRed
                Filled Black -> Theme.black
                Empty        -> Theme.grey
        cellElt = case cell of
                  Filled _   -> if neighbours < 2 || neighbours > 3
                                then Icons.dead Icons.normal
                                else (neighbours |> String.fromInt) |> text
                  Empty      -> (neighbours |> String.fromInt) |> text
    in Input.button [width fill
        , height fill
        , Background.color color
        , Border.color Theme.white
        , Border.rounded 6
        , Border.width 3]
        { onPress = if isFilled cell || state.twoPlayersGame.remaining==0
                    then Nothing
                    else (PutToken state.twoPlayersGame.turn pos) |> Just,
          label = cellElt |> el [centerX, centerY, Font.color Theme.white] }

-- Hard mode: cell die and spawn
renderCellHard: AppState -> Position -> Cell Player -> Element Msg
renderCellHard state pos cell =
    let redNeighbours = state.twoPlayersGame.board |> countNeighboursForPlayer pos Red
        blackNeighbours = state.twoPlayersGame.board |> countNeighboursForPlayer pos Black
        neighbours = redNeighbours + blackNeighbours
        eltFontColor = if (isEmpty cell) && neighbours==3 && redNeighbours > blackNeighbours then Theme.darkRed
                               else if (isEmpty cell) && neighbours==3 && blackNeighbours > redNeighbours then Theme.black
                               else Theme.white
        color = case cell of
                Filled Red   -> Theme.darkRed
                Filled Black -> Theme.black
                Empty        -> if neighbours==3 then Theme.darkGrey else Theme.grey
        cellElt = case cell of
                  Filled _   -> if neighbours < 2 || neighbours > 3
                                then Icons.dead Icons.normal
                                else (neighbours |> String.fromInt) |> text
                  Empty      -> if neighbours==3
                                then Icons.alive Icons.normal
                                else (neighbours |> String.fromInt) |> text
    in Input.button [width fill
        , height fill
        , Background.color color
        , Border.color Theme.white
        , Border.rounded 6
        , Border.width 3]
        { onPress = if isFilled cell || state.twoPlayersGame.remaining==0
                    then Nothing
                    else (PutToken state.twoPlayersGame.turn pos) |> Just,
          label = cellElt |> el [centerX, centerY, Font.color eltFontColor] }

colorForPlayer: Player -> Color
colorForPlayer player =
    case player of
        Red   -> Theme.darkRed
        Black -> Theme.black

module View.WinnerScreen exposing (winnerScreen)

import Element exposing (Color, Element, alignLeft, alignRight, centerX, centerY, column, el, fill, padding, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import GoL.TwoPlayers as TwoPlayers exposing (Difficulty(..), Player(..), Victory(..), countFilled)
import State.AppState exposing (AppState, Screen(..))
import Update.Msg exposing (Msg(..))
import View.Theme as Theme


winnerScreen: AppState -> Element Msg
winnerScreen state = column [
        centerX,
        centerY,
        spacing 10,
        padding 20,
        Border.rounded 20,
        Border.width 3,
        Border.color Theme.darkRed]
    [ renderHeader state
    , renderScores state
    , highlightWinner state
    , renderButtons state]

renderHeader: AppState -> Element Msg
renderHeader _ = el [width fill, centerX, Font.size 48, Font.bold, Font.color Theme.darkRed] ("And the winner is ..." |> text)

renderScores: AppState -> Element Msg
renderScores state = row [centerX, centerY] [
    row [width fill, spacing 5] [
        "Player Red: "
        |> text
        |> el [Font.color Theme.darkRed, alignLeft] ,
        countFilled Red state.twoPlayersGame |> String.fromInt |> text |> el [Font.color Theme.darkRed, Font.bold, alignLeft ]
    ,el [centerX] (" VS " |> text)
    ,row [width fill, spacing 5] [
        "Player Black: "
        |> text
        |> el [Font.color Theme.black, alignRight] ,
        countFilled Black state.twoPlayersGame |> String.fromInt |> text |> el [Font.color Theme.black, Font.bold, alignRight ]
    ]
 ]]

highlightWinner: AppState -> Element Msg
highlightWinner state =
    let winner = TwoPlayers.winner state.twoPlayersGame
        playerColor = \player -> case player of
                                  Red   -> Theme.darkRed
                                  Black -> Theme.black
    in
    case winner of
        Draw          -> "Nobody, this is a draw !" |> text |> el [centerX]
        Winner player -> (player |> Debug.toString) ++ " Player"
            |> text
            |> el [centerX, Font.size 48, Font.bold, Font.color (playerColor player)]
        NotFinished   -> "Game interrupted. Not winners." |> text |> el [centerX]

renderButtons: AppState -> Element Msg
renderButtons state = row [alignRight] [
    Input.button [
        width fill
        , padding 10
        , Border.rounded 5
        , Background.color Theme.black
        , Font.color Theme.white]
        { onPress = Just (ChangeScreen NewGameScreen),
          label = "Play again" |> text}
 ]
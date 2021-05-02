module View.NewGameScreen exposing (newGameScreen)

import Element exposing (Element, alignLeft, alignRight, behindContent, centerX, centerY, column, el, fill, height, padding, paddingEach, paragraph, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import GoL.TwoPlayers exposing (Difficulty(..))
import State.AppState exposing (AppState, Screen(..))
import Update.Msg exposing (Msg(..))
import View.Theme as Theme



newGameScreen: AppState -> Element Msg
newGameScreen state = column [
    centerX,
    centerY,
    spacing 10,
    padding 20,
    Border.rounded 20,
    Border.width 3,
    Border.color Theme.darkRed]
    [
        renderHeader state
        , renderWizard state
        , renderHelp state
        , renderButtons state
    ]

renderHeader: AppState -> Element Msg
renderHeader _ = column [width fill, spacing 10] [
        el [width fill, centerX, Font.size 96, Font.bold, Font.color Theme.darkRed] ("GoL 42" |> text)
        , el [width fill, centerX, Font.size 14, Font.italic, Font.color Theme.darkRed]
            ("A Game Of Life for 2 players, inspired by Conway's Game Of Life." |> text)
    ]

renderWizard: AppState -> Element Msg
renderWizard state = column [padding 20] [
  row [spacing 10, width fill] [
    "Grid dimension: " |> text |> el [width <| px 150]
    , row [spacing 5] [
        ((String.fromInt state.newGame.width) ++ " x " ++ (String.fromInt state.newGame.height)) |> text |> el [width <| px 100]
        , slider (\val -> NewGameGridDimensions (round val) (round val)) 11 23 4 state.newGame.width |>  el [width <| px 75]
     ]
  ]
  , row [spacing 10, width fill] [
    "Token per turn: "|> text |> el [width <| px 150]
    , row [spacing 5] [
        (String.fromInt state.newGame.tokens) |> text |> el [width <| px 100]
        , slider (\val -> NewGameTokenCount (round val)) 1 8 1 state.newGame.tokens |>  el [width <| px 75]
      ]
  ]
  , row [spacing 10, width fill] [
      "Rules: "|> text |> el [width <| px 150]
      , renderDifficulty state
  ]
 ]

renderButtons: AppState -> Element Msg
renderButtons state = row [alignRight] [
    Input.button [
        width fill
        , padding 10
        , Border.rounded 5
        , Background.color Theme.black
        , Font.color Theme.white]
        { onPress = Just CreateNewTwoPlayersGame,
          label = "New Game" |> text}
 ]

renderHelp: AppState -> Element Msg
renderHelp state =
    let easy = [ "Easy mode" |> text |> el [Font.bold, Font.size 14]
                , "In this mode, an empty cells with exactly 3 filled neighbours will come to life at the next turn."
                    |> text |> el [Font.italic, Font.size 11]
               , "It will be of the color of the player having most neighbours around. (eg. 2 Red cells and 1 Black means the empty cell will become Red)"
                    |> text |> el [Font.italic, Font.size 11]
               , "The winner is the player with most cells at the end (ie when there is no more empty cells that can appears)"
                    |> text |> el [Font.italic, Font.size 11]]
        normal = ["Normal mode" |> text |> el [Font.bold, Font.size 14]
                 , "In this mode, cells need to survive to the next generation."
                    |> text |> el [Font.italic, Font.size 11]
                 , "Surviving cells are the one with exactly 2 or 3 neighbours. Other cells will die."
                    |> text |> el [Font.italic, Font.size 11]
                 ,"The game ends when one player doesn't have any cells remaining at the next generation."
                    |> text |> el [Font.italic, Font.size 11]]
        hard   = ["Hard mode" |> text |> el [Font.bold, Font.size 14]
                  , "In the Hard mode, cells need to survive to the next generation, and new cells can come to life (combination of easy and normal modes)"
                    |> text |> el [Font.italic, Font.size 11]
                  , "- Surviving cells are the ones with exactly 2 or 3 neighbours."
                    |> text |> el [Font.italic, Font.size 11]
                  , "- Empty cells with exactly 3 neighbours will come to life"
                    |> text |> el [Font.italic, Font.size 11]]
        content = case state.newGame.difficulty of
                  Easy   -> easy
                  Normal -> normal
                  Hard   -> hard
    in
    column [width <| px 450, alignLeft, Border.width 1, Border.rounded 3, padding 10]
        (content |> List.map (List.singleton >> paragraph [Font.size 11, Font.italic]))

slider: (Float -> Msg) -> Int -> Int -> Int -> Int -> Element Msg
slider onChange min max step current =
    Input.slider  [ width fill
      , height <| px 30
      , behindContent <|
        -- Slider track
        el [ width fill
            , height <| px 3
            , centerY
            , Background.color Theme.blue
            , Border.rounded 2
            ]
            Element.none
        ]
        { onChange = onChange
          , label = Input.labelHidden "Hidden"
          , min = Basics.toFloat min
          , max = Basics.toFloat max
          , step = step |> Basics.toFloat |> Just
          , value = Basics.toFloat current
          , thumb = Input.defaultThumb
         }

type ButtonPosition
    = First
    | Mid
    | Last

renderDifficulty: AppState -> Element Msg
renderDifficulty state =
    Input.radioRow
        [ Border.rounded 6
          , Border.shadow { offset = ( 0, 0 ), size = 3, blur = 10, color = Theme.lightGrey }
        ]
        { onChange = (\opt -> NewGameDifficulty opt)
        , selected = Just state.newGame.difficulty
        , label = Input.labelHidden ""
         , options = [
                Input.optionWith Easy     <| button First "Easy"
                , Input.optionWith Normal <| button Mid "Normal"
                , Input.optionWith Hard   <| button Last "Hard"
            ]
         }

button position label state =
    let borders =
            case position of
                First -> { left = 2, right = 2, top = 2, bottom = 2 }
                Mid -> { left = 0, right = 2, top = 2, bottom = 2 }
                Last -> { left = 0, right = 2, top = 2, bottom = 2 }
        corners =
            case position of
                First -> { topLeft = 6, bottomLeft = 6, topRight = 0, bottomRight = 0 }
                Mid -> { topLeft = 0, bottomLeft = 0, topRight = 0, bottomRight = 0 }
                Last -> { topLeft = 0, bottomLeft = 0, topRight = 6, bottomRight = 6 }
    in el [ paddingEach { left = 5, right = 5, top = 5, bottom = 5 }
            , Border.roundEach corners
            , Border.widthEach borders
            , Border.color Theme.blue
            , Background.color <|
                if state == Input.Selected then  Theme.lightBlue
                else Theme.white
            ] <| el [ centerX, centerY ] <| text label
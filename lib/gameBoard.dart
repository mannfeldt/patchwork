import 'package:flutter/material.dart';
import 'package:patchwork/boardTile.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/square.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/gamestate.dart';

class GameBoard extends StatelessWidget {
  List<Square> cells = [];
  final Board board;
  GameBoard({this.board});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    Player currentPlayer = gameState.getCurrentPlayer();
    cells = _computeCells(currentPlayer.board);
    return Table(children: _createGridCells(currentPlayer.board));
      // If the widget is visible, animate to 0.0 (invisible)
  }

  List<TableRow> _createGridCells(Board board) {
    List<TableRow> rows = <TableRow>[];
    for (int row = 0; row < board.cols; row++) {
      rows.add(TableRow(children: [
        Row(
          children: getRow(row, board),
        ),
      ]));
    }
    return rows;
  }

  List<BoardTile> getRow(int rowIdx, Board board) {
    List<BoardTile> row = <BoardTile>[];
    for (int col = 0; col < board.rows; col++) {
      Square square = cells.firstWhere((s) => s.x == col && s.y == rowIdx);
      row.add(BoardTile(square: square));
    }
    return row;
  }

  List<Square> _computeCells(Board board) {
    List<Square> cells = <Square>[];
    //här ska jag loopa igenom alla board.pieces läsa boardposition och sen applicera den positionen på varje shape.square
    //och använd square för att se om det finns knapp på den och använd piece för att se färgen
    //sen målar jag då i den tabledatan som vi landar på.

    // ska jag använda boardShaper etc? för att rita ut pieces och finns dt ingen piece så blir den default grå etc.
    // är själva drop target på hela gameBoard eller indivuduella suares?

    // jag tror inte andra projektet har droptargets utan lever på positionen vid drag end helt och hållet
    // jag ska inte tänka så mycket på hans projetk. Vad behöver jag+
    // 1. 9x9 drop targets BoardTile(Square square). den tar in square som antingen är en square uträknad från player.board.pieces.shape eller en tom square
    // 2. BoardTile är en widget som har droptarget, en square som säger var den är på boarden
    // 3. eventhandlers för att hantera när man släpper en patch på boardtile, då ska piecen som ligger i data valideras om det är en lämlig placering och sen läggas till i gamestate.currentplayer.board.pieces glöm inte lägga till piece.boardposition baserat på boardtilens.square.x och y
    // 4. boardTile ser ut som en container eller något som har en bakgrundsfärg och en ev. icon i sig som är hasButton (square.color, square.hasbutton)
// forstätt här nu. fixa dragtargets på tile eller över board. använd offset osv osv för att räkna ut var man släpper den?
// eller bara räkna vilken/vilksa square man släppet den på. debuga eventlisteners
    // frågan r om det blir knas när jag släpper biten över flera targets? körs eventen på alla då? kan ju vara både bra och dåligt.

    for (int i = 0; i < board.squares.length; i++) {
      Square s = board.squares[i];
      cells.add(s);
    }

    for (int i = 0; i < board.hovered.length; i++) {
      Square square = board.hovered[i];
      bool exists = cells.any((s) => s.x == square.x && s.y == square.y);
      if (!exists) {
        cells.add(square);
      }
    }

    for (int y = 0; y < board.rows; y++) {
      for (int x = 0; x < board.cols; x++) {
        Square square = new Square(x, y, false);
        bool exists = cells.any((s) => s.x == square.x && s.y == square.y);
        if (!exists) {
          square.color = Colors.white;
          cells.add(square);
        }
      }
    }

    return cells;
  }
}

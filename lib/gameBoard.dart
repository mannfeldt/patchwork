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
    Board currentBoard = gameState.getCurrentBoard();
    List<Square> shadow = gameState.getBoardHoverShadow();
    cells = _computeCells(currentBoard, shadow);
    return Table(children: _createGridCells(currentBoard));
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

  List<Square> _computeCells(Board board, List<Square> shadow) {
    List<Square> cells = <Square>[];
    for (int i = 0; i < board.squares.length; i++) {
      Square s = board.squares[i];
      cells.add(s);
    }

    if (shadow != null) {
      for (int i = 0; i < shadow.length; i++) {
        Square square = shadow[i];
        bool exists = cells.any((s) => s.x == square.x && s.y == square.y);
        if (!exists) {
          cells.add(square);
        }
      }
    }

    for (int y = 0; y < board.rows; y++) {
      for (int x = 0; x < board.cols; x++) {
        Square square = new Square(x, y, false, Colors.white);
        bool exists = cells.any((s) => s.x == square.x && s.y == square.y);
        if (!exists) {
          cells.add(square);
        }
      }
    }

    return cells;
  }
}

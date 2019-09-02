import 'package:flutter/material.dart';
import 'package:patchwork/components/boardTile.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/square.dart';

class GameBoard extends StatefulWidget {
  final Board board;
  final bool useLootboxes;
  final double tileSize;
  GameBoard({this.board, this.useLootboxes, this.tileSize});

  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  List<Square> cells = [];

  @override
  Widget build(BuildContext context) {
    cells = _computeCells(widget.board);
    return Table(
      children: _createGridCells(widget.board),
      defaultColumnWidth: FixedColumnWidth(widget.tileSize * 9),
    );
  }

  List<TableRow> _createGridCells(Board board) {
    List<TableRow> rows = <TableRow>[];
    for (int row = 0; row < board.rows; row++) {
      rows.add(TableRow(children: [
        Row(
          children: getRow(row, board),
        ),
      ]));
    }
    return rows;
  }

  List<Widget> getRow(int rowIdx, Board board) {
    List<Widget> row = <Widget>[];
    for (int col = 0; col < board.cols; col++) {
      Square square = cells.firstWhere((s) => s.x == col && s.y == rowIdx);
      row.add(BoardTile(square: square));
    }
    if (widget.useLootboxes) {
      bool isBingo = board.player.bingos.contains(rowIdx);
      //sista kolumnen
      Widget lootbox = Container(
          decoration: new BoxDecoration(
              color: Colors.white,
              border:
                  new Border.all(color: Colors.white, width: boardTilePadding)),
          height: widget.tileSize,
          width: widget.tileSize,
          child: Icon(
            isBingo ? Icons.check_box : Icons.check_box_outline_blank,
            color: lootBoxColor,
          ));
      row.add(lootbox);
    }
    return row;
  }

  List<Square> _computeCells(Board board) {
    List<Square> cells = <Square>[];
    cells.addAll(board.squares);

    //ta fram denna för att få en skugga. lägg till onAccept på boardtile för att få rödmarkerat vid fel placering
    // if (shadow != null && shadow[0].color==Colors.red) {
    //   for (int i = 0; i < shadow.length; i++) {
    //     Square square = shadow[i];
    //     bool exists = cells.any((s) => s.x == square.x && s.y == square.y);
    //     if (!exists) {
    //       cells.add(square);
    //     }
    //   }
    // }

    for (int y = 0; y < board.rows; y++) {
      for (int x = 0; x < board.cols; x++) {
        Square square = new Square(x, y, false, null);
        square.color = board.player.color.withOpacity(0.2);
        bool exists = cells.any((s) => s.samePositionAs(square));
        if (!exists) {
          cells.add(square);
        }
      }
    }

    return cells;
  }
}

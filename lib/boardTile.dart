import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/square.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/gamestate.dart';
import 'package:patchwork/constants.dart';

class BoardTile extends StatelessWidget {
  final Square square;
  BoardTile({this.square});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    Player currentPlayer = gameState.getCurrentPlayer();
//detta ska vara en dragtarget sen med lite eventlisteners etc

    return DragTarget<Piece>(
        builder: (context, List<Piece> candidateData, rejectedData) {
      return Container(
        child: Text(square.hasButton ? "B" : ""),
        decoration: new BoxDecoration(
            color: square.color,
            border: !square.filled
                ? new Border.all(color: Colors.black87, width: boardTilePadding)
                : null),
        height: gameState.getBoardTileSize(),
        width: gameState.getBoardTileSize(),
      );
    }, onWillAccept: (data) {
      bool accepted = true;
      List<Square> tmpSquares = data.shape
          .map((s) => new Square(s.x + square.x, s.y + square.y, true))
          .toList();
      //skicka upp denna till parent som kan puta ner till till alla effected boardTiles. sätt border grön/röd runt dessa
      accepted = !tmpSquares.any((s) =>
          s.x < 0 ||
          s.y < 0 ||
          s.x >= currentPlayer.board.cols ||
          s.y >= currentPlayer.board.rows);
      if (accepted) {
        for (int i = 0; i < currentPlayer.board.squares.length; i++) {
          Square inUse = currentPlayer.board.squares[i];
          bool occupied =
              tmpSquares.any((s) => s.x == inUse.x && s.y == inUse.y);
          if (occupied) {
            accepted = false;
            break;
          }
        }
      }

      for (int i = 0; i < tmpSquares.length; i++) {
        Square s = tmpSquares[i];
        s.filled = true;
        s.color = accepted ? data.color : Colors.red;
      }
      gameState.updateHoverBoard(tmpSquares);

      return accepted;
    }, onLeave: (data) {
      gameState.updateHoverBoard([]);
    }, onAccept: (data) {
      if (data.size == 1) {
        gameState.extraPiecePlaced(data, square.x, square.y);
      } else {
        gameState.putPiece(data, square.x, square.y);
      }
    });
  }
}

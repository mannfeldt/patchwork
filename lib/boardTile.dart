import 'package:flutter/material.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/piece.dart';
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
    Board currentBoard = gameState.getCurrentBoard();
    return DragTarget<Piece>(
        builder: (context, List<Piece> candidateData, rejectedData) {
      return Container(
        child: square.hasButton
            ? Icon(
                Icons.radio_button_checked,
                color: Colors.blue,
              )
            : null,
        decoration: new BoxDecoration(
            color: square.color,
            border: !square.filled
                ? new Border.all(color: currentBoard.player.color, width: boardTilePadding)
                : null),
        height: gameState.getBoardTileSize(),
        width: gameState.getBoardTileSize(),
      );
    }, onWillAccept: (data) {
      bool accepted = true;

      List<Square> shadow = gameState.setHoveredBoardTile(square);

       accepted = gameState.isValidPlacement(shadow);

      for (int i = 0; i < shadow.length; i++) {
        Square s = shadow[i];
        s.filled = true;
        s.color = accepted ? data.color : Colors.red;
      }

      return accepted;
    }, onLeave: (data) {
      gameState.cleaHoverBoardTile();

      //!TEST
      //gameState.rotatePiece(gameState.getDraggedPiece());
      // jag måste kunna klicka på knapparna medan jag drar annars är det ingen ide att fixa resten. för steg två är att f till en repaint på piceshaper när man roterar osv
    }, onAccept: (data) {
      if (data.size == 1) {
        gameState.extraPiecePlaced(data, square.x, square.y);
      } else {
        gameState.putPiece(data, square.x, square.y);
      }
    });
  }
}

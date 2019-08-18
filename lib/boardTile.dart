import 'package:flutter/material.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/patchwork_icons_icons.dart';
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
    double tileSize = gameState.getBoardTileSize();
    return DragTarget<Piece>(
        builder: (context, List<Piece> candidateData, rejectedData) {
      if (square.filled) {
        Widget buttonWidget = square.hasButton
            ? Icon(
                PatchworkIcons.button_icon,
                color: buttonColor.withOpacity(0.8),
                size: tileSize,
              )
            : Container();
        return Stack(children: <Widget>[
          Image.asset(
            "assets/" + square.imgSrc,
            width: tileSize,
          ),
          buttonWidget
        ]);
      } else {
        return Container(
          decoration: new BoxDecoration(
              color: square.color,
              border:
                  new Border.all(color: Colors.white, width: boardTilePadding)),
          height: tileSize,
          width: tileSize,
        );
      }
    }, onWillAccept: (data) {
      bool accepted = true;

      List<Square> shadow = gameState.getShadow(square);

      accepted = gameState.isValidPlacement(shadow);

      // for (int i = 0; i < shadow.length; i++) {
      //   Square s = shadow[i];
      //   s.filled = true;
      //   s.color = accepted ? data.color : Colors.red;
      // }

      return accepted;
    }, onAccept: (data) {
      if (data.size == 1) {
        gameState.extraPiecePlaced(data, square.x, square.y);
      } else {
        gameState.putPiece(data, square.x, square.y);
      }
    });
  }
}

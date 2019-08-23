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
    double tileSize = gameState.getBoardTileSize();
    return DragTarget<Piece>(
        builder: (context, List<Piece> candidateData, rejectedData) {
      if (square.filled) {
        List<Widget> children = [
          Image.asset(
            "assets/" + square.imgSrc,
            width: tileSize,
          )
        ];
        Widget buttonWidget = square.hasButton
            ? Icon(
                PatchworkIcons.button_icon,
                color: buttonColor,
                size: tileSize,
              )
            : Container();
        children.add(buttonWidget);
        //topposition = bottom: tilesize/2
        //leftpostion =           right: tileSize/2, and rotatedBox
        if (square.topStitching) {
          Widget topStitch = Positioned(
            bottom: tileSize / 2,
            child: Icon(
              PatchworkIcons.clothing_stitches,
              size: tileSize,
              color: stitchColor,
            ),
          );
          children.add(topStitch);
        }
        if (square.leftStitching) {
          Widget leftStitch = Positioned(
            right: tileSize / 2,
            child: RotatedBox(
                quarterTurns: 1,
                child: Icon(
                  PatchworkIcons.clothing_stitches,
                  size: tileSize,
                  color: stitchColor,
                )),
          );
          children.add(leftStitch);
        }

        return Stack(overflow: Overflow.visible, children: children);
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

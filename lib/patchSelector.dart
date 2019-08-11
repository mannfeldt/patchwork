import 'package:flutter/material.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/patch.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/gamestate.dart';

class PatchSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    Player currentPlayer = gameState.getCurrentPlayer();
    List<Piece> pieces = gameState.getGamePieces();
    bool extraPieceCollected = gameState.getExtraPieceCollected();
    if (extraPieceCollected) {
      Piece extraPiece = new Piece.single(0);
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              "Free patch",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Patch(extraPiece,
                draggable: true,
                patchSize: gameState.getBoardTileSize(),
                img: gameState.getImg())
          ],
        ),
      );
    }
    return Expanded(
        child: Container(
      padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: pieces.length,
          itemBuilder: (context, index) {
            Piece piece = pieces[index];
            return Container(
                width: MediaQuery.of(context).size.width / 3,
                alignment: Alignment.topCenter,
                child: Column(
                  children: <Widget>[
                    Patch(piece,
                        draggable: index < 3 && piece.selectable,
                        patchSize: gameState.getBoardTileSize(),
                        img: gameState.getImg()),
                    Expanded(
                      child: Container(
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.rotate_left),
                                  onPressed: () {
                                    gameState.rotatePiece(piece);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.flip),
                                  onPressed: () {
                                    gameState.flipPiece(piece);
                                  },
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.attach_money,
                                      color: piece.cost > currentPlayer.buttons
                                          ? Colors.red
                                          : Colors.black87,
                                    ),
                                    Text(
                                      piece.cost.toString(),
                                      style: TextStyle(
                                          color:
                                              piece.cost > currentPlayer.buttons
                                                  ? Colors.red
                                                  : Colors.black87),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.access_time,
                                    ),
                                    Text(piece.time.toString())
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ));
          }),
    ));
  }
}

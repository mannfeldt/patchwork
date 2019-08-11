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
      return Container(
        alignment: Alignment.topCenter,
        child: Patch(extraPiece,
            draggable: true,
            patchSize: gameState.getBoardTileSize(),
            img: gameState.getImg()),
      );
    }
    return Expanded(
        child: Container(
      padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    Text(
                      "cost: " +
                          piece.cost.toString() +
                          " time: " +
                          piece.time.toString(),
                      style: TextStyle(
                          color: piece.cost > currentPlayer.buttons
                              ? Colors.red
                              : Colors.black87),
                    )
                  ],
                ));
          }),
    ));
  }
}

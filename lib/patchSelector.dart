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
      return Column(
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
              patchDragStartCallback: gameState.setDraggedPiece,
              patchDroppedCallback: gameState.dropDraggedPiece,
              patchSize: gameState.getBoardTileSize(),
              img: gameState.getImg())
        ],
      );
    }
    Piece draggedPiece = gameState.getDraggedPiece();

    // TODO frågan är om det är så enkelt att rotera biten samtidigt som den dras?
    // funktionellt så fungerar det. visuellt så är det bara hovereffecken som roteras.
    //objetet jag drar i roteras inte, antar att ingen repaint körs? debugga och kolla det.
    //NOPE det sker ingen repaint i patchShaper.dart det måste det göra vid rotation..
    //kolla hur jag kan få till det. lägg in gamestate i patch/patchshaper så den mål om varje gång notify körs i state?

    //googla på "flutter draggable update color while dragging" eller liknande
    //behöver helt enkelt kunna ändra något på objektet jag drar i medan jag drar

    //nu fungerar det typ! behöver bara få till repaint direkt.
    return Stack(
      children: <Widget>[
        Visibility(
            visible: draggedPiece == null,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            maintainInteractivity: true,
            child: Container(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pieces.length,
                  itemBuilder: (context, index) {
                    Piece piece = pieces[index];
                    bool draggable = index < 3 && piece.selectable;
                    double tileSize = gameState.getBoardTileSize();
                    return Container(
                        width: MediaQuery.of(context).size.width / 3,
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: <Widget>[
                            ConstrainedBox(
                                constraints: new BoxConstraints(
                                  minHeight: tileSize * 3,
                                ),
                                child: Card(
                                  elevation: draggable ? 3 : 0,
                                  child: Center(
                                    child: Patch(piece,
                                        draggable: draggable,
                                        patchSize: tileSize,
                                        patchDragStartCallback:
                                            gameState.setDraggedPiece,
                                        patchDroppedCallback:
                                            gameState.dropDraggedPiece,
                                        img: gameState.getImg()),
                                  ),
                                )),
                            Expanded(
                              child: Container(
                                child: Stack(
                                  alignment: Alignment.topCenter,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.attach_money,
                                              color: piece.cost >
                                                      currentPlayer.buttons
                                                  ? Colors.red
                                                  : Colors.black87,
                                              size: 18,
                                            ),
                                            Visibility(
                                              visible:
                                                  piece.costAdjustment != 0,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 2.0, 0),
                                                child: Text(
                                                  (piece.cost).toString(),
                                                  style: TextStyle(
                                                      color: piece.cost >
                                                              currentPlayer
                                                                  .buttons
                                                          ? Colors.red
                                                          : Colors.black87,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      fontSize: 18),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              (piece.cost +
                                                      piece.costAdjustment)
                                                  .toString(),
                                              style: TextStyle(
                                                  color: piece.cost >
                                                          currentPlayer.buttons
                                                      ? Colors.red
                                                      : Colors.black87,
                                                  fontSize: 18),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.access_time,
                                            ),
                                            Text(piece.time.toString()),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ));
                  }),
            )),
        Visibility(
          visible: draggedPiece != null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  iconSize: gameState.getBoardTileSize() * 2,
                  icon: Icon(
                    Icons.rotate_left,
                  ),
                  onPressed: () {
                    gameState.rotatePiece(draggedPiece);
                  },
                ),
                IconButton(
                  iconSize: gameState.getBoardTileSize() * 2,
                  icon: Icon(Icons.flip),
                  onPressed: () {
                    gameState.flipPiece(draggedPiece);
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

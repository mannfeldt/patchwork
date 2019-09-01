import 'dart:math';

import 'package:flutter/material.dart';
import 'package:patchwork/components/scissor.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/components/patch.dart';
import 'package:patchwork/utilities/patchwork_icons_icons.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/logic/gamestate.dart';

class PatchSelector extends StatefulWidget {
  @override
  _PatchSelectorState createState() => _PatchSelectorState();
}

class _PatchSelectorState extends State<PatchSelector> {
  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    Player currentPlayer = gameState.getCurrentPlayer();
    List<Piece> pieces = gameState.getGamePieces();
    bool extraPieceCollected = gameState.getExtraPieceCollected();
    bool scissorCollected = gameState.getScissorCollected();

    int pieceIndex = gameState.getPieceMarkerIndex();
    double tileSize = gameState.getBoardTileSize();
    bool animatingButtons = gameState.getButtonsAnimation();

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
              single: true,
              patchDragStartCallback: gameState.setDraggedPiece,
              patchDroppedCallback: gameState.dropDraggedPiece,
              patchSize: tileSize)
        ],
      );
    }
    if (scissorCollected) {
      Piece scissor = new Piece.single(0);
      scissor.state = "scissor";
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            "Cut a square with the scissor",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          Scissor(
              scissor: scissor,
              patchDragStartCallback: gameState.setDraggedPiece,
              patchDroppedCallback: gameState.dropDraggedPiece,
              size: tileSize)
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

    double patchItemSize = MediaQuery.of(context).size.width / 3;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (pieceIndex > -1 && !animatingButtons) {
        // alltfungerar bra förutom när man lägger en bit och får en extra bit. då hamnar inte selectorn på rätt index.. den tar inte
        // den gör inte cuten alls
        await _scrollController.animateTo(
          (patchItemSize * pieceIndex),
          curve: Curves.easeIn,
          duration: const Duration(milliseconds: 400),
        );
        await gameState.clearPieceMarkerIndex(true);
        _scrollController.jumpTo(0);
      }
    });

    return IndexedStack(
      index: draggedPiece == null ? 0 : 1,
      children: <Widget>[
        Container(
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: lazyLoadPieces,
              controller: _scrollController,
              itemBuilder: (context, index) {
                Piece piece = pieces[index];
                bool draggable =
                    index < 3 && piece.selectable && pieceIndex == -1;
                return new PatchListItem(
                    tileSize: tileSize,
                    draggable: draggable,
                    piece: piece,
                    currentPlayer: currentPlayer);
              }),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                iconSize: tileSize * 2,
                icon: Icon(
                  Icons.rotate_left,
                ),
                onPressed: () {
                  gameState.rotatePiece(draggedPiece);
                },
              ),
              IconButton(
                iconSize: tileSize * 2,
                icon: Icon(Icons.flip),
                onPressed: () {
                  gameState.flipPiece(draggedPiece);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PatchListItem extends StatelessWidget {
  const PatchListItem({
    Key key,
    @required this.tileSize,
    @required this.draggable,
    @required this.piece,
    @required this.currentPlayer,
  }) : super(key: key);

  final double tileSize;
  final bool draggable;
  final Piece piece;
  final Player currentPlayer;

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    double fontSize = max(18, tileSize / 3);
    return Container(
        width: MediaQuery.of(context).size.width / 3,
        alignment: Alignment.topCenter,
        child: Column(
          children: <Widget>[
            ConstrainedBox(
              constraints: new BoxConstraints(
                minHeight: tileSize * 3,
              ),
              child: Patch(piece,
                  draggable: draggable,
                  patchSize: tileSize,
                  patchDragStartCallback: gameState.setDraggedPiece,
                  patchDroppedCallback: gameState.dropDraggedPiece,
                  flipCallback: gameState.flipPiece,
                  rotateCallback: gameState.rotatePiece),
            ),
            Expanded(
              child: Container(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              PatchworkIcons.button_icon,
                              color: piece.cost > currentPlayer.buttons
                                  ? Colors.red
                                  : buttonColor,
                              size: fontSize,
                            ),
                            Visibility(
                              visible: piece.costAdjustment != 0,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 2.0, 0),
                                child: Text(
                                  (piece.cost).toString(),
                                  style: TextStyle(
                                      color: piece.cost > currentPlayer.buttons
                                          ? Colors.red
                                          : Colors.black87,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: fontSize),
                                ),
                              ),
                            ),
                            Text(
                              (piece.cost + piece.costAdjustment).toString(),
                              style: TextStyle(
                                  color: piece.cost > currentPlayer.buttons
                                      ? Colors.red
                                      : Colors.black87,
                                  fontSize: fontSize),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.access_time,
                              size: fontSize,
                            ),
                            Text(
                              piece.time.toString(),
                              style: TextStyle(fontSize: fontSize),
                            ),
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
  }
}

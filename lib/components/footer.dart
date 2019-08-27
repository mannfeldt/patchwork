import 'package:flutter/material.dart';
import 'package:patchwork/models/player.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/logic/gamestate.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    Player currentPlayer = gameState.getCurrentPlayer();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(children: <Widget>[
          Icon(
            currentPlayer.isAi ? Icons.android : Icons.person,
            color: currentPlayer.color,
          ),
          Text(
            currentPlayer.name,
            style: TextStyle(fontSize: 20),
          )
        ]),
        Row(children: <Widget>[
          Icon(Icons.attach_money),
          Text(
            currentPlayer.buttons.toString(),
            style: TextStyle(fontSize: 20),
          ),
        ]),
        IconButton(
          icon: Icon(Icons.skip_next),
          tooltip: "pass",
          onPressed: () {
            if (gameState.getDraggedPiece() == null &&
                gameState.getExtraPieceCollected() == false &&
                gameState.getScissorCollected() == false) {
              gameState.pass();
            }
          },
        )
      ],
    );
  }
}

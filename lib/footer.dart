import 'package:flutter/material.dart';
import 'package:patchwork/models/player.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/gamestate.dart';

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
          Text(currentPlayer.name)
        ]),
        Row(children: <Widget>[
          Icon(Icons.attach_money),
          Text(currentPlayer.buttons.toString()),
        ]),
        IconButton(
          icon: Icon(Icons.skip_next),
          tooltip: "pass",
          onPressed: () {
            gameState.pass();
          },
        )
      ],
    );
  }
}

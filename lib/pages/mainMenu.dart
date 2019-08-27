import 'package:flutter/material.dart';
import 'package:patchwork/logic/gamestate.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Center(
      child: Column(children: <Widget>[
        RaisedButton(
          onPressed: () {
            gameState.startQuickPlay();
          },
          child: Text("Quick play 1v1"),
        ),
        RaisedButton(
          onPressed: () {
            gameState.setView("setup");
          },
          child: Text("New game"),
        )
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:patchwork/gamestate.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Center(
      child: Column(children: <Widget>[
        RaisedButton(
          onPressed: () {},
          child: Text("Quick play (1v1) default setup"),
        ),
        RaisedButton(
          onPressed: () {
            gameState.setView("setup");
          },
          child: Text("New game (custom players and setup)"),
        )
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:patchwork/components/highscoreTable.dart';
import 'package:patchwork/logic/gamestate.dart';
import 'package:patchwork/logic/sessionstate.dart';
import 'package:patchwork/pages/setup.dart';
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Setup()),
            );
          },
          child: Text("New game"),
        ),
        RaisedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text("Patchwork"),
                      ),
                      body: SafeArea(child: HighscoreTable()))),
            );
          },
          child: Text("Highscore"),
        )
      ]),
    );
  }
}

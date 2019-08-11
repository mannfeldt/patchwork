import 'package:flutter/material.dart';
import 'package:patchwork/models/player.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/gamestate.dart';

class EndScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    List<Player> players = gameState.getPlayers();
    players.sort((a, b) => b.score.compareTo(a.score));

    return SafeArea(
        child: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 25.0),
          child: Text(
            "Game finished",
            style: TextStyle(fontSize: 28.0),
          ),
        ),
        Column(
          children: players
              .map((p) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 0.0),
                    child: ListTile(
                      leading: Text(p.name),
                      dense: false,
                      trailing: Text(p.score.toString()),
                    ),
                  ))
              .toList(),
        ),
        RaisedButton(
          onPressed: () {
            gameState.restartApp();
          },
          child: Text("New game"),
        )
      ],
    )));
  }
}

import 'package:flutter/material.dart';
import 'package:patchwork/models/player.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/logic/gamestate.dart';

class EndScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    List<Player> players = gameState.getPlayers();
    players.sort((a, b) => b.score.compareTo(a.score));

    return Center(
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
        Expanded(
            child: ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 0),
              child: Column(
                children: <Widget>[
                  ListTile(
                    dense: true,
                    title: Text(player.name),
                    leading: Icon(player.isAi ? Icons.android : Icons.person,
                        color: player.color),
                    trailing: Text(
                      player.score.toString(),
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Divider(
                    height: 0,
                    color: Colors.black87,
                  )
                ],
              ),
            );
          },
        )),
        RaisedButton(
          onPressed: () {
            gameState.restartApp();
          },
          child: Text("New game"),
        )
      ],
    ));
  }
}

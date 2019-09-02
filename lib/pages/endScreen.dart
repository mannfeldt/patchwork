import 'package:flutter/material.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/utilities/utils.dart';
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
            int buttonsScore = player.buttons;
            int emptySpacesScore = Utils.emptyBoardSpaces(player.board) * 2;
            int extraPoints = player.hasSevenBySeven ? 7 : 0;
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
              child: Column(
                children: <Widget>[
                  ListTile(
                    dense: true,
                    title: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(player.name),
                        ),
                        CircleAvatar(
                          backgroundColor: buttonColor,
                          child: Text(buttonsScore.toString(),
                              style: TextStyle(color: Colors.white)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Text(
                              emptySpacesScore.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: extraPoints != 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(emptySpacesScore.toString(),
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Text(player.score.toString(),
                              style: TextStyle(color: Colors.black87)),
                        )
                      ],
                    ),
                    leading: Icon(player.isAi ? Icons.android : Icons.person,
                        color: player.color),
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

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:patchwork/components/newHighscoreTable.dart';
import 'package:patchwork/logic/highscoreState.dart';
import 'package:patchwork/models/highscore.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/logic/gamestate.dart';

class EndScreen extends StatefulWidget {
  @override
  _EndScreenState createState() => _EndScreenState();
}

class _EndScreenState extends State<EndScreen> {
  bool isShowingHighscoreDialog = false;

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final highscoreState = Provider.of<HighscoreState>(context);

    GameMode gameMode = gameState.getGameMode();

    void _saveHighscore(Highscore highscore, String name, Player player) async {
      Highscore newHighscore = highscore;
      newHighscore.name = name;
      newHighscore.time = Timestamp.now();
      newHighscore.mode = gameState.getGameMode().toString();
      await highscoreState.saveHighscore(newHighscore, player);
    }

    List<Player> players = gameState.getPlayers();
    players.sort((a, b) => b.score.compareTo(a.score));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isShowingNewHighscore = highscoreState.isShowingNewHighscore();
      for (int i = 0; i < players.length; i++) {
        Timeframe newHighscoreTimeFrame =
            highscoreState.getNewHighscoreTimeframe(players[i], gameMode);
        if (newHighscoreTimeFrame != null && !isShowingNewHighscore) {
          List<Highscore> highscores =
              highscoreState.getHighscores(newHighscoreTimeFrame, gameMode);
          Highscore newHighscore =
              new Highscore(players[i], i);

          if (highscores.length == highscoreLimit) {
            highscores[highscoreLimit - 1] = newHighscore;
          } else {
            highscores.add(newHighscore);
          }
          highscores.sort((a, b) => a.compareTo(b));
          highscoreState.setShowingNewHighscore(true);

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Dialog(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${timeFrameName[newHighscoreTimeFrame]} new highscore",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    NewHighscoreTable(
                      highscores: highscores,
                      player: players[i],
                      callbackSaveHighscore: _saveHighscore,
                      newHighscore: newHighscore,
                    ),
                  ],
                )),
              );
            },
          );
        }
      }
    });

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 25.0),
          child: Text(
            "Game finished",
            style: TextStyle(fontSize: 28.0),
          ),
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.separated(
            itemCount: players.length,
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.black87,
              );
            },
            itemBuilder: (context, index) {
              final player = players[index];
              int totalScore = player.score.total;
              return ListTile(
                leading: Image.file(player.screenshot),
                title: Text(
                  player.displayname,
                  style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w400),
                ),
                trailing: CircleAvatar(
                  backgroundColor: totalScore < 0 ? Colors.red : Colors.blue,
                  child: Text(
                    totalScore.abs().toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        )),
        OutlineButton(
          onPressed: () {
            gameState.restartApp();
          },
          textColor: Colors.blue,
          borderSide: BorderSide(color: Colors.blue),
          child: Text("Continue"),
        ),
      ],
    ));
  }
}

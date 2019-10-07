import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:patchwork/components/newHighscoreTable.dart';
import 'package:patchwork/components/scoreBubbles.dart';
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

    void _saveHighscore(Highscore highscore, String name) async {
      Highscore newHighscore = highscore;
      newHighscore.name = name;
      newHighscore.time = Timestamp.now();
      newHighscore.mode = gameModeName[gameState.getGameMode()];
      await highscoreState.saveHighscore(newHighscore);
    }

    List<Player> players = gameState.getPlayers();
    players.sort((a, b) => b.score.compareTo(a.score));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //int nextPlayerIndex = sessionState.getNextPlayerToCheckHIghscore();
      bool isShowingNewHighscore = highscoreState.isShowingNewHighscore();
      for (int i = 0; i < players.length; i++) {
        Timeframe newHighscoreTimeFrame =
            highscoreState.getNewHighscoreTimeframe(players[i], gameMode);
        if (newHighscoreTimeFrame != null && !isShowingNewHighscore) {
          List<Highscore> highscores =
              highscoreState.getHighscores(newHighscoreTimeFrame, gameMode);
          Highscore newHighscore = new Highscore(players[i], highscores.length);
          if (highscores.any((h) => newHighscore.isSameAs(h))) {
            continue;
          }
          if (highscores.length == highscoreLimit) {
            highscores[highscoreLimit - 1] = newHighscore;
          } else {
            highscores.add(newHighscore);
          }
          highscores.sort((a, b) => a.compareTo(b));
          highscoreState.setShowingNewHighscore(true);

          //  highscoreScreen ser bra ut, förutom att det är gamla highscore som inte längre finns i firebase som visas??

          //  i endscreen så får jag upp tomma tables.?? och bara en dialog fast än det är 2 som borde visas. fast den kanske ska vara tom då jag körde bingo?

          // if (!highscores
          //     .any((h) => h.userId == newHighscore.userId && h.isNew)) {
          //   highscores.add(newHighscore);
          // }

          //skulle kunna visa flera i stack t.ex?

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                  child: Column(
                children: <Widget>[
                  Text(
                    "New " +
                        timeFrameName[newHighscoreTimeFrame] +
                        " Highscore",
                    style: TextStyle(fontSize: 22),
                  ),
                  NewHighscoreTable(
                    highscores: highscores,
                    callbackSaveHighscore: _saveHighscore,
                    newHighscore: newHighscore,
                  ),
                ],
              ));
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
            int ranking =
                highscoreState.getAllTimeRanking(gameMode, player.score.total);
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
              child: Column(
                children: <Widget>[
                  ListTile(
                    dense: true,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(player.name),
                        ScoreBubbles(
                          plus: player.score.plus,
                          minus: player.score.minus,
                          extra: player.score.extra,
                          total: player.score.total,
                        ),
                      ],
                    ),
                    leading: Icon(player.isAi ? Icons.android : Icons.person,
                        color: player.color),
                    trailing: SizedBox(
                        width: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Icon(Icons.score),
                            Text(ranking.toString())
                          ],
                        )),
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

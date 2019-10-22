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
      newHighscore.mode = gameModeName[gameState.getGameMode()];
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
          Highscore newHighscore = new Highscore(players[i], highscores.length);

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

//TODO
//testa allt och pusha ovanstående
//5. fixa leaderboard knappen i mainmenu. fixa en paktiskt bra ikon eller lös på annat sätt?
//7. pusha och bygg till play store
//8. kolla över vad jag ska prioritera next, snyggare setup.dart. (ta bort isandroid, lägg till emoji-picker som blir spelpjäs: det sparas som en textsträng. behöver bara ha någon validering så att man bara kan välja emoji)
//alt1. ha ett vanligt textfält med patternvalidering som måste vara unicode för emojis. användaren använder keybord emojis
//alt2 jag väljer ut en lista med godkända emojis/unicodes som man kan välja mellan. eller om jag kan hämta ut det från någon api eller liknande?selectbox?
//alt3. https://pub.dev/packages/emoji_picker https://stackoverflow.com/questions/44936239/displaying-text-with-emojis-on-flutter
//försökt med alt 3 först. ANNARS alt 2 med en gridlist över massa emojis
//får inte ta någon som redan funnits.
//spara detta till highscore tillsammans med ett 3 bokstäverl långt namn.
//i setup så playername kan jag skita i? ersätts med emoji.
//quickstart ska tilldelas en random emoji

//kolla på personliga/lokala rekord. spara bara en siffra i bakgrunden till prefernces. en per mode "local_highscore_bingo" = "30"
//updatera den vid nytt avslutat spel om det är högre. möjligen en dialog.simpleannouncement för att meddela detta.
//se taiga för bättre hantering när jag väl fått in firebase users. då kan jag spara personliga highscore kopplat till users med bild och allt och visa upp på snyggt vis.

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
              int ranking = highscoreState.getAllTimeRanking(
                  gameMode, player.score.total);
              int totalScore = player.score.total;
              return ListTile(
                leading: Image.file(player.screenshot),
                title: Text(
                  player.name,
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
        RaisedButton(
          onPressed: () {
            gameState.restartApp();
          },
          child: Text("Main menu"),
        )
      ],
    ));
  }
}

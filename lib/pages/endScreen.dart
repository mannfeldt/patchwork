import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:patchwork/components/gameBoard.dart';
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
      //int nextPlayerIndex = sessionState.getNextPlayerToCheckHIghscore();
      bool isShowingNewHighscore = highscoreState.isShowingNewHighscore();
      for (int i = 0; i < players.length; i++) {
        Timeframe newHighscoreTimeFrame =
            highscoreState.getNewHighscoreTimeframe(players[i], gameMode);
        if (newHighscoreTimeFrame != null && !isShowingNewHighscore) {
          List<Highscore> highscores =
              highscoreState.getHighscores(newHighscoreTimeFrame, gameMode);
          Highscore newHighscore = new Highscore(players[i], highscores.length);
          // if (highscores.any((h) => newHighscore.isSameAs(h))) {
          //   continue;
          // }
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
              return Dialog(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    //någon snygg default backgrund för fadeimage.assetnetwork? lägg någon random bild från nåot spel där? eller bara en place holder om är en gif? kan jag ha en gif här förresten? vore coolt
                    //! ta fram en gif som bara är för en spelare. cropa så det bara är gameboard som syns. tänk på att gömma recording ikonen.
                    //! tillfälligt stäng av animationer för buttons? men animation för lootbox får vara kvar.
                    //! lägg till 1000 buttons att börja med så att det inte blir ett problem. gör banan också extra lång, jag kan avsluta när jag är nöjd då och klippa i videon
                    //! testa göra det lite i slowmotion för jag kan ändå speeda upp det och vill
                    //! kan bli lite jobbigt för ögat att ha två giffar spelandes samtiidgt? det jobbiga är speeden och att det är två spelare istället för en.
                    //! om det inte går att spela med en spelare så klipp bort den andra spelaren bara.
                    //! ha en rätt hög men jämn opacity
                    //! ett alt är att man behöver kliicka för att starta gifen? det är först den färdiga boardet som visas som stillbild sen när man klickar så körs gifen en loop?
                    //! ha någon förklarande ikon över bilden så att man förstår att det inte handlar om att man startar något spel utan bara gifen?
                    //! men börja med att ta fram gifs och se hur de ser ut

                    //! snygga till endscreen och newhighscreotable också. leaberboard.dart är jag nöjd med. kör på samma ty pav design. fast skipp kanske datum etc
                    // 3.5 fixa till highscoreknappen? hur vill jag faktiskt ha den? som den är fast med en bättre ikon? text och ikon?
                    // 4. lägg tillbaka alla fixar för att testa helhelten (autoscroll timeboard, pieces, timeboard classic finishindex, calculatescore)
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

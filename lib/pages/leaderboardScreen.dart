import 'package:flutter/material.dart';
import 'package:patchwork/components/leaderboard.dart';
import 'package:patchwork/logic/highscoreState.dart';
import 'package:patchwork/models/highscore.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatefulWidget {
  LeaderboardScreen();

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  static const WEEKLY = 0;
  static const MONTHLY = 1;
  static const ALL = 2;
  static const CLASSIC = 0;
  static const BINGO = 1;

  static const timeFrames = [
    Timeframe.WEEK,
    Timeframe.MONTH,
    Timeframe.ALL_TIME
  ];

  static const gameModes = [GameMode.CLASSIC, GameMode.BINGO];

  var isSelectedMode = [true, false];
  var isSelectedTime = [true, false, false];

  @override
  Widget build(BuildContext context) {
    final highscoreState = Provider.of<HighscoreState>(context);
    List<Highscore> highscores = highscoreState.getAllHightscores();
    Widget tableWidget;
    if (highscores == null) {
      //sessionS.fetchHighscores();
      tableWidget = CircularProgressIndicator();
    } else {
      int selectedTimeIndex = isSelectedTime.indexWhere((i) => i);
      Timeframe selectedTimeframe = timeFrames[selectedTimeIndex];
      int selectedModeIndex = isSelectedMode.indexWhere((i) => i);
      GameMode selectedGameMode = gameModes[selectedModeIndex];

      List<Highscore> filteredHighscores =
          highscoreState.getHighscores(selectedTimeframe, selectedGameMode);
      tableWidget = Leaderboard(
        highscores: filteredHighscores,
        timeframe: selectedTimeframe,
      );

      //används för att visa om currentPlayer är med i
    }
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            "Leaderboard",
            style: TextStyle(fontSize: 28),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              children: [
                Text("Classic"),
                Text("Bingo"),
              ],
              onPressed: (int index) {
                setState(() {
                  for (int buttonIndex = 0;
                      buttonIndex < isSelectedMode.length;
                      buttonIndex++) {
                    if (buttonIndex == index) {
                      isSelectedMode[buttonIndex] = true;
                    } else {
                      isSelectedMode[buttonIndex] = false;
                    }
                  }
                });
              },
              isSelected: isSelectedMode,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              children: [
                Text("Weekly"),
                Text("Monthly"),
                Text("All time"),
              ],
              onPressed: (int index) {
                setState(() {
                  for (int buttonIndex = 0;
                      buttonIndex < isSelectedTime.length;
                      buttonIndex++) {
                    if (buttonIndex == index) {
                      isSelectedTime[buttonIndex] = true;
                    } else {
                      isSelectedTime[buttonIndex] = false;
                    }
                  }
                });
              },
              isSelected: isSelectedTime,
            ),
          ),
          tableWidget
        ],
      ),
    );
  }
}

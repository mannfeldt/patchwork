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
    List<Highscore> highscores = highscoreState.getAllHightscores() ?? [];
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
    }

    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.transparent,
          expandedHeight: 180,
          pinned: true,
          elevation: 0,
          title: Text(
            'Leaderboard',
            style: TextStyle(
                fontFamily: 'Helvetica',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24),
          ),
          flexibleSpace: Container(
            padding: EdgeInsets.only(top: 80, left: 40),
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15.0,
                    spreadRadius: 1.0,
                    offset: Offset(
                      0,
                      2.0,
                    ),
                  )
                ],
                gradient: new LinearGradient(
                    colors: [Colors.blue.shade200, Colors.blue.shade700],
                    begin: const FractionalOffset(1.0, 1.0),
                    end: const FractionalOffset(0.2, 0.2),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25))),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ToggleButtons(
                      color: Colors.white,
                      highlightColor: Colors.blue.shade800,
                      fillColor: Colors.blue.shade800,
                      selectedColor: Colors.white,
                      renderBorder: false,
                      children: [
                        Text(
                          "Classic",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Bingo",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ToggleButtons(
                      renderBorder: false,
                      color: Colors.white,
                      fillColor: Colors.blue.shade800,
                      highlightColor: Colors.blue.shade800,
                      selectedColor: Colors.white,
                      children: [
                        Text(
                          "Weekly",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Monthly",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "All time",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                ),
              ],
            ),
          ),
        ),
        tableWidget
      ],
    );
  }
}

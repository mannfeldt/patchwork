import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:patchwork/logic/sessionstate.dart';
import 'package:patchwork/models/highscore.dart';
import 'package:provider/provider.dart';

class HighscoreTable extends StatefulWidget {
  HighscoreTable();

  @override
  _HighscoreTableState createState() => _HighscoreTableState();
}

class _HighscoreTableState extends State<HighscoreTable> {
  static const WEEKLY = 0;
  static const MONTHLY = 1;
  static const ALL = 2;
  static const STANDARD = 0;
  static const BINGO = 1;
  var isSelectedMode = [true, false];
  var isSelectedTime = [true, false, false];

  @override
  Widget build(BuildContext context) {
    final sessionS = Provider.of<SessionState>(context);
    List<Highscore> highscores = sessionS.getHightscores();

    if (highscores == null) {
      FutureBuilder<List<Highscore>>(
        future: sessionS.fetchHighscores(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Highscore>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return new CircularProgressIndicator();
          }
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          return Text("what");
        },
      );
      return new CircularProgressIndicator();
    }

    Widget table;
    if (isSelectedMode[STANDARD]) {
      List<Highscore> standardHighscores =
          highscores.where((h) => h.mode == "STANDARD").toList();
      standardHighscores[0].time = Timestamp.fromDate(DateTime.utc(2019, 9, 2));
      if (isSelectedTime[WEEKLY]) {
        standardHighscores =
            standardHighscores.where((h) => isThisWeek(h.time)).toList();
      } else if (isSelectedTime[MONTHLY]) {
        standardHighscores =
            standardHighscores.where((h) => isThisMonth(h.time)).toList();
      }

      table = _createTable(standardHighscores);
      //här skapar jag ena eller andra tablen som bara tar in den mode som stämmer
      //hur ska jag hantera vecka och måndag och all time?
      //liknande sätt?
    } else if (isSelectedMode[BINGO]) {
      List<Highscore> bingoHighscores =
          highscores.where((h) => h.mode == "BINGO").toList();
      if (isSelectedTime[WEEKLY]) {
        bingoHighscores =
            bingoHighscores.where((h) => isThisWeek(h.time)).toList();
      } else if (isSelectedTime[MONTHLY]) {
        bingoHighscores =
            bingoHighscores.where((h) => isThisMonth(h.time)).toList();
      }
      table = _createTable(bingoHighscores);
    }
    //används för att visa om currentPlayer är med i
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            "Highscore",
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
          table,
        ],
      ),
    );
  }
}

bool isThisWeek(Timestamp timestamp) {
  var now = new DateTime.now();
  var date =
      new DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch);
  var diff = now.difference(date);
  int daysAgo = diff.inDays;

//detnna är felvänt
  return daysAgo > 7 && date.weekday < now.weekday;
}

bool isThisMonth(Timestamp timestamp) {
  var now = new DateTime.now();
  var date =
      new DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch);
  return date.year == now.year && date.month == now.month;
}

Widget _createTable(List<Highscore> highscores) {
  return DataTable(
    columns: <DataColumn>[
      DataColumn(
        label: Text('Name'),
      ),
      DataColumn(
        label: Text('Score'),
      ),
      DataColumn(
        label: Text('Date'),
      )
    ],
    rows: highscores
        .map(
          (itemRow) => DataRow(
            cells: [
              DataCell(
                Text(itemRow.name),
                placeholder: false,
              ),
              DataCell(
                Text(itemRow.score.toString()),
                placeholder: false,
              ),
              DataCell(
                Text(itemRow.time.toDate().toString()),
                placeholder: false,
              )
            ],
          ),
        )
        .toList(),
  );
}

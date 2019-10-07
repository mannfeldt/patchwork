import 'package:flutter/material.dart';
import 'package:patchwork/components/scoreBubbles.dart';
import 'package:patchwork/models/highscore.dart';
import 'package:intl/intl.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/utilities/utils.dart';
// hmmmm varför vill den inte funkadå?
// testa flutter clean, delete yaml.lock etc etc

class HighscoreTable extends StatefulWidget {
  final List<Highscore> highscores;
  final Timeframe timeframe;
  HighscoreTable({this.highscores, this.timeframe});

  @override
  _HighscoreTableState createState() => _HighscoreTableState();
}

class _HighscoreTableState extends State<HighscoreTable> {
  @override
  Widget build(BuildContext context) {
    DateFormat df;
    switch (widget.timeframe) {
      case Timeframe.WEEK:
        df = DateFormat(DateFormat.WEEKDAY);
        break;
      case Timeframe.MONTH:
        df = DateFormat(DateFormat.MONTH_DAY);
        break;
      default:
        df = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY);
        break;
    }

    return Expanded(
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              dataRowHeight: 60.0,
              columnSpacing: 20.0,
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
              rows: widget.highscores
                  .map(
                    (highscore) => DataRow(
                      cells: [
                        DataCell(
                          Text(highscore.name),
                        ),
                        DataCell(ScoreBubbles(
                          plus: highscore.score,
                          minus: highscore.scoreMinus,
                          extra: highscore.scoreExtra,
                          total: highscore.score -
                              highscore.scoreMinus +
                              highscore.scoreExtra,
                        )),
                        DataCell(
                          Text(df.format(highscore.time.toDate())),
                          placeholder: false,
                        )
                      ],
                    ),
                  )
                  .toList(),
            )));
  }
}

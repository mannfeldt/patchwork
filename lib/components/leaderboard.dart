import 'package:flutter/material.dart';
import 'package:patchwork/models/highscore.dart';
import 'package:intl/intl.dart';
import 'package:patchwork/utilities/constants.dart';

class Leaderboard extends StatefulWidget {
  final List<Highscore> highscores;
  final Timeframe timeframe;
  Leaderboard({this.highscores, this.timeframe});

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  @override
  Widget build(BuildContext context) {
    DateFormat df;
    switch (widget.timeframe) {
      case Timeframe.WEEK:
        df = DateFormat("EEEE HH:mm");
        break;
      case Timeframe.MONTH:
        df = DateFormat(DateFormat.MONTH_DAY);
        break;
      default:
        df = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY);
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ListView.separated(
        itemCount: widget.highscores.length,
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.black87,
          );
        },
        itemBuilder: (context, index) {
          Highscore highscore = widget.highscores[index];
          int totalScore = highscore.getTotal();
          return ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(right: 24),
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(fontSize: 20, color: Colors.blue),
                    )),
                FadeInImage.assetNetwork(
                  image: highscore.thumbnail,
                  fadeOutDuration: Duration(milliseconds: 200),
                  fadeInDuration: Duration(milliseconds: 400),
                  placeholder:
                      "assets/transparent.png",
                ),
              ],
            ),
            title: Text(
              highscore.name,
              style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w400),
            ),
            subtitle: Text(df.format(highscore.time.toDate())),
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
    );
  }
}

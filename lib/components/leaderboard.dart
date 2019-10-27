import 'dart:ui';

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

    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      if (index + 1 > widget.highscores.length) {
        return Padding(
          padding: const EdgeInsets.only(right: 16, left: 16, top: 16),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(right: 24),
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(fontSize: 20, color: Colors.blue),
                    )),
                Image.asset("assets/transparent.png")
              ],
            ),
            title: Text(
              "-",
              style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w400),
            ),
            subtitle: Text(" "),
            trailing: Text("-"),
          ),
        );
      }
      Highscore highscore = widget.highscores[index];
      int totalScore = highscore.getTotal();
      return Padding(
        padding: const EdgeInsets.only(right: 16, left: 16, top: 16),
        child: ListTile(
          onTap: () => {
            Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Hero(
                          transitionOnUserGestures: true,
                          tag: highscore.thumbnail,
                          child: Image.network(
                            highscore.thumbnail,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  );
                }))
          },
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(right: 24),
                  child: Text(
                    (index + 1).toString(),
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  )),
              Hero(
                tag: highscore.thumbnail,
                child: FadeInImage.assetNetwork(
                  image: highscore.thumbnail,
                  fadeOutDuration: Duration(milliseconds: 200),
                  fadeInDuration: Duration(milliseconds: 400),
                  placeholder: "assets/transparent.png",
                ),
              ),
            ],
          ),
          title: Text(
            highscore.displayname,
            style: TextStyle(
                fontSize: 20, letterSpacing: 1.5, fontWeight: FontWeight.w400),
          ),
          subtitle: Text(df.format(highscore.time.toDate())),
          trailing: CircleAvatar(
            backgroundColor: totalScore < 0 ? Colors.red : Colors.blue,
            child: Text(
              totalScore.abs().toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }, childCount: highscoreLimit));
  }
}

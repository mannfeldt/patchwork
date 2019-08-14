import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/models/player.dart';

class TimeBoardTile extends StatefulWidget {
  final bool hasButton;
  final bool hasPiece;
  final bool isStartTile;
  final List<Player> players;
  final Player currentPlayer;
  final bool isGoalLine;
  final double tileWidth;
  final bool isCrowded;

  TimeBoardTile(
      {this.hasButton,
      this.hasPiece,
      this.players,
      this.isStartTile,
      this.isGoalLine,
      this.tileWidth,
      this.isCrowded,
      this.currentPlayer});

  @override
  _TimeBoardTileState createState() => _TimeBoardTileState();
}

class _TimeBoardTileState extends State<TimeBoardTile> {
  @override
  Widget build(BuildContext context) {
    double tileWidth = widget.tileWidth;
    if (widget.isGoalLine) {
      tileWidth = MediaQuery.of(context).size.width - timeBoardTileWidth;
    }
    if (widget.isStartTile) tileWidth *= 2;
    List<Widget> tileContent = [];
    List<Widget> avatars = [];

    if (widget.isCrowded) {
      avatars.addAll(widget.players
          .sublist(0, 3)
          .map((p) => Icon(
                p.isAi ? Icons.android : Icons.person,
                color: p.color,
              ))
          .toList());
      avatars.add(
        Text(
          "...",
          style: TextStyle(fontSize: 24),
        ),
      );
    } else if (widget.players.length > 0) {
      avatars.addAll(widget.players
          .map((p) => Icon(
                p.isAi ? Icons.android : Icons.person,
                color: p.color,
              ))
          .toList());
    }
    if (widget.hasButton) {
      tileContent.add(Icon(
        Icons.radio_button_checked,
        color: Colors.blue.withOpacity(0.5),
      ));
    }
    if (widget.hasPiece) {
      tileContent.add(Icon(
        Icons.stop,
        color: Colors.brown,
      ));
    }

    return Container(
      width: tileWidth,
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: tileContent,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: avatars,
          )
        ],
      ),
    );
  }
}

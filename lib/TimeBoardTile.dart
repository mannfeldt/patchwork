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

  TimeBoardTile(
      {this.hasButton,
      this.hasPiece,
      this.players,
      this.isStartTile,
      this.isGoalLine,
      this.currentPlayer});

  @override
  _TimeBoardTileState createState() => _TimeBoardTileState();
}

class _TimeBoardTileState extends State<TimeBoardTile> {
  @override
  Widget build(BuildContext context) {
    double tileWidth = timeBoardTileWidth;
    if (widget.isGoalLine) tileWidth = MediaQuery.of(context).size.width - timeBoardTileWidth;
    if (widget.isStartTile) tileWidth *= 2;
    List<Widget> tileContent = [];
    if (widget.players.length > 0) {
      tileContent.addAll(widget.players
          .map((p) => Icon(
                p.isAi ? Icons.android : Icons.person,
                color: p.color,
              ))
          .toList());
    }
    if (widget.hasButton) {
      tileContent.add(Icon(
        Icons.radio_button_checked,
        color: Colors.blue,
      ));
    }
    if (widget.hasPiece) {
      tileContent.add(Icon(
        Icons.stop,
        color: Colors.brown,
      ));
    }

    return Container(
      height: timeBoardTileHeight,
      width: tileWidth,
      decoration: new BoxDecoration(
          border:
              new Border.all(color: Colors.black87, width: boardTilePadding)),
      child: Row(
        children: tileContent,
      ),
    );
  }
}

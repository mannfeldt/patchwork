import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (widget.players.length > 0) {
      double iconSize = 20;
      double paddingLeft = ((tileWidth - iconSize) / widget.players.length);
      paddingLeft = min(paddingLeft, iconSize);
      for (int i = 0; i < widget.players.length; i++) {
        Player p = widget.players[i];
        Widget avatar = Padding(
          padding: EdgeInsets.fromLTRB(paddingLeft * i, 0, 0, 0),
          child: Icon(
            p.isAi ? Icons.android : Icons.person,
            size: iconSize,
            color: p.color,
          ),
        );
        avatars.add(avatar);
      }
    }

    if (widget.hasButton) {
      tileContent.add(Center(
          child: Icon(
        Icons.radio_button_checked,
        color: Colors.blue.withOpacity(0.5),
      )));
    }
    if (widget.hasPiece) {
      tileContent.add(Center(
          child: Container(
              padding: EdgeInsets.all(tileWidth / 10),
              child: Image.asset(
                "assets/single.png",
              ))));
    }

    return Container(
      width: tileWidth,
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: tileContent,
          ),
          Stack(
            children: avatars,
            alignment: Alignment.centerLeft,
          )
        ],
      ),
    );
  }
}

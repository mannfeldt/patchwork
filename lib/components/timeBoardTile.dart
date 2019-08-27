import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/utilities/patchwork_icons_icons.dart';

class TimeBoardTile extends StatefulWidget {
  final bool hasButton;
  final bool hasPiece;
  final bool isStartTile;
  final List<Player> players;
  final Player currentPlayer;
  final bool isGoalLine;
  final double tileWidth;
  final bool isCrowded;
  final int index;

  TimeBoardTile(
      {this.hasButton,
      this.hasPiece,
      this.players,
      this.isStartTile,
      this.isGoalLine,
      this.tileWidth,
      this.isCrowded,
      this.index,
      this.currentPlayer});

  @override
  _TimeBoardTileState createState() => _TimeBoardTileState();
}

class _TimeBoardTileState extends State<TimeBoardTile> {
  @override
  Widget build(BuildContext context) {
    double tileWidth = widget.tileWidth;

    if (widget.isGoalLine) {
      tileWidth = MediaQuery.of(context).size.width - tileWidth;
    }
    if (widget.isStartTile) {
      tileWidth *= 2;
    }
    List<Widget> tileContent = [];
    List<Widget> avatars = [];
    if (widget.players.length > 0) {
      double iconSize = widget.tileWidth / 3;
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

    if (widget.hasButton && !widget.isGoalLine) {
      tileContent.add(Center(
          child: Icon(
        PatchworkIcons.button_icon,
        color: buttonColor.withOpacity(0.8),
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
      decoration: widget.isGoalLine
          ? BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/goalline.jpg"),
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.3), BlendMode.dstATop),
                  repeat: ImageRepeat.repeat),
            )
          : null,
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: tileContent,
          ),
          Center(
            child: Stack(
              children: avatars,
              alignment: Alignment.centerLeft,
            ),
          ),
        ],
      ),
    );
  }
}

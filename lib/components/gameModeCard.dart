import 'dart:math';

import 'package:flutter/material.dart';
import 'package:patchwork/pages/setup.dart';
import 'package:patchwork/utilities/constants.dart';

class GameModeCard extends StatefulWidget {
  const GameModeCard({
    Key key,
    this.quickplayCallback,
    this.backgroundImage,
    this.bakgroundVideo,
    this.gameMode,
    this.title,
    this.subtitle,
  }) : super(key: key);
  final Function quickplayCallback;
  final String backgroundImage;
  final String bakgroundVideo;
  final GameMode gameMode;
  final String title;
  final String subtitle;

  @override
  _GameModeCardState createState() => _GameModeCardState();
}

class _GameModeCardState extends State<GameModeCard> {
  bool playGif = false;

  void toggleGif() {
    setState(() {
      playGif = !playGif;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: max(min(MediaQuery.of(context).size.width - 24 - 220, 300), 160),
      child: Card(
        margin: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                    onTap: toggleGif,
                    child: playGif
                        ? Image.asset(
                            widget.bakgroundVideo,
                            fit: BoxFit.contain,
                            alignment: Alignment.topLeft,
                          )
                        : Stack(
                            children: <Widget>[
                              Opacity(
                                opacity: 0.4,
                                child: Image.asset(
                                  widget.backgroundImage,
                                  fit: BoxFit.contain,
                                  alignment: Alignment
                                      .topLeft,
                                ),
                              ),
                              Positioned.fill(
                                child: Center(
                                    child: Icon(
                                  Icons.play_circle_outline,
                                  size: 64,
                                  color: Colors.blue.shade500.withOpacity(0.8),
                                )),
                              )
                            ],
                          )),
              ),
              Container(
                width: 220,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 8.0, right: 0.0, bottom: 0.0),
                        child: ListTile(
                          isThreeLine: true,
                          dense: true,
                          title: Text(widget.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                fontSize: 22,
                                color: Colors.blue.shade300,
                              )),
                          subtitle: Text(widget.subtitle),
                        ),
                      ),
                      ButtonTheme.bar(
                          child: ButtonBar(
                        children: <Widget>[
                          OutlineButton(
                            onPressed: () {
                              widget.quickplayCallback(widget.gameMode);
                            },
                            textColor: Colors.blue,
                            borderSide: BorderSide(color: Colors.blue),
                            child: Text("Quick Play"),
                          ),
                          OutlineButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Setup(gameMode: widget.gameMode)),
                              );
                            },
                            borderSide: BorderSide(color: Colors.blue),
                            textColor: Colors.blue,
                            child: Text("New Game"),
                          )
                        ],
                      ))
                    ]),
              )
            ]),
      ),
    );
  }
}

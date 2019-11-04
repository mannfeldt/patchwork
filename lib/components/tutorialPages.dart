import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:youtube_player/youtube_player.dart';

class TutorialPages extends StatefulWidget {
  final GameMode gameMode;

  TutorialPages({this.gameMode});

  @override
  _TutorialPagesState createState() => _TutorialPagesState();
}

class _TutorialPagesState extends State<TutorialPages> {
  PageController controller = new PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: AlertDialog(
          contentPadding: EdgeInsets.all(2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              YoutubePlayer(
                context: context,
                source: "k-NVaMt1o60",
                quality: YoutubeQuality.HD,
                autoPlay: true,
                hideShareButton: true,
                showThumbnail: true,
                switchFullScreenOnLongPress: true,
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: new SizedBox(
                  width: double.infinity,
                  child: OutlineButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    borderSide: BorderSide(color: Colors.blue),
                    textColor: Colors.blue,
                    child: Text("Close"),
                  ),
                ),
              )
            ],
          )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:patchwork/utilities/constants.dart';
//import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_player/youtube_player.dart';

class TutorialPages extends StatefulWidget {
  final GameMode gameMode;

  TutorialPages({this.gameMode});

  @override
  _TutorialPagesState createState() => _TutorialPagesState();
}

class _TutorialPagesState extends State<TutorialPages> {
  PageController controller = new PageController(initialPage: 0);
  VideoPlayerController _controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        contentPadding: EdgeInsets.all(2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            YoutubePlayer(
              context: context,
              source: "k-NVaMt1o60",
              quality: YoutubeQuality.HD,
              // callbackController is (optional).
              // use it to control player on your own.
              callbackController: (controller) {
                _controller = controller;
              },
              autoPlay: true,
              hideShareButton: true,
              showThumbnail: true,
              switchFullScreenOnLongPress: true,
            ),
            // YoutubePlayer(
            //   context: context,
            //   videoId: "VYM8T09fAJw",
            //   flags: YoutubePlayerFlags(
            //     mute: false,
            //     autoPlay: true,
            //     forceHideAnnotation: true,
            //     showVideoProgressIndicator: true,
            //   ),
            //   videoProgressIndicatorColor: Colors.amber,
            //   progressColors: ProgressColors(
            //     playedColor: Colors.amber,
            //     handleColor: Colors.amberAccent,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: new SizedBox(
                width: double.infinity,
                // height: double.infinity,
                child: RaisedButton(
                    child: Text("close"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
            )
          ],

          // fixa en bra regel genomgång här. basics illustrerade med korta gifs. (placering av bit, vad button på tidslinjen gör, singlepatch/bingo, )
          // förklara hur man får poäng, förklara vems tur det är, förklara vad som sker när man valt en bit(marökren flyttar sig)
          // reglerna blir i en scoll barl ista. eller pages som man kan swipea med en schysst navigotr nertill som indikerar vilken sida man är på? blåa prickar
          // paginator. https://pub.dev/packages/page_indicator  https://pub.dev/packages/dots_indicator#-readme-tab-
          // https://stackoverflow.com/questions/54012407/is-there-a-way-to-create-an-alertdialog-with-pageview-in-flutter
          // en förklaring per page. med en gif eller bild som är stor nog att täcka upp beroende på skrämensstorlek/boardTileSize
          // kolla på patchworks regelhäfte och ta därfirån de relvanta delarna som stämmer även här och som inte förklaras i showcase delen
          // planera vilka delar som ska med och vilka bilder/gifar som behöver tillverkas

          //byt icon från $ till buttonicons
          //fixa padding runt showcase på footern framförallt
          // extra off-topic: VISA UTRÄKNINGEN AV poängen i endgame alltså t.ex 45b + svenbyseven - (5tomma * 2) = 35 score
        ));
  }
}

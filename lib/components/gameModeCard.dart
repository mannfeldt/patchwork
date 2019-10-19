import 'package:flutter/material.dart';
import 'package:patchwork/pages/setup.dart';
import 'package:patchwork/utilities/constants.dart';

class GameModeCard extends StatelessWidget {
  const GameModeCard({
    Key key,
    this.quickplayCallback,
    this.backgroundImageSrc,
    this.gameMode,
    this.title,
    this.subtitle,
  }) : super(key: key);

  final Function quickplayCallback;
  final String backgroundImageSrc;
  final GameMode gameMode;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: Card(
        margin: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
        child: Stack(children: <Widget>[
          Positioned.fill(
            child: Container(
              child: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.black, Colors.transparent],
                    ).createShader(
                        Rect.fromLTRB(0, 0, rect.width * 0.4, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: FadeInImage.assetNetwork(//här vill jag ha en bild på klart bräde. med en gesture grej som känner av om man klickarp åden så switchar den till gifen
                  //togglar om igen om man klickar igen. 
                    image: backgroundImageSrc,
                    placeholder: "assets/gameplay.gif",
                    fit: BoxFit.contain,
                    alignment: Alignment.topLeft,
                  )),
            ),
          ),
          Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    isThreeLine: true,
                    leading: SizedBox(
                      width: 130,
                    ),
                    title: Text(title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontSize: 22,
                          color: Colors.blue.shade300,
                        )),
                    subtitle: Text(subtitle),
                  ),
                ),
                ButtonTheme.bar(
                    child: ButtonBar(
                  children: <Widget>[
                    OutlineButton(
                      onPressed: () {
                        quickplayCallback(gameMode);
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
                              builder: (context) => Setup(gameMode: gameMode)),
                        );
                      },
                      borderSide: BorderSide(color: Colors.blue),
                      textColor: Colors.blue,
                      child: Text("New Game"),
                    )
                  ],
                ))
              ])
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:page_indicator/page_indicator.dart';
import 'package:patchwork/logic/gamestate.dart';
import 'package:patchwork/pages/highscoreScreen.dart';
import 'package:patchwork/pages/setup.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/utilities/patchwork_icons_icons.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Center(
      child: Stack(children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/background2.jpg',
                fit: BoxFit.contain,
              ),
            )),
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
              child: Text(
                "Patchwork",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            Card(
              margin: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images.png"),
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.center,
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.2), BlendMode.dstATop),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      leading: Icon(PatchworkIcons.button_icon),
                      title: Text('Classic'),
                      subtitle: Text(
                          'Classic game of patchwork. Identical to the board game.'),
                    ),
                    ButtonTheme.bar(
                      child: ButtonBar(
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () {
                              gameState.startQuickPlay(GameMode.CLASSIC);
                            },
                            textColor: Colors.white,
                            child: Text("Quick Play"),
                          ),
                          RaisedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Setup(gameMode: GameMode.CLASSIC)),
                              );
                            },
                            textColor: Colors.white,
                            child: Text("New Game"),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/download (1).jpg"),
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.center,
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.2), BlendMode.dstATop),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      leading: Icon(PatchworkIcons.button_icon),
                      title: Text('Bingo'),
                      subtitle: Text(
                          'Patchwork with a twist! For every line you complete in the same color you get extra loot.'),
                    ),
                    ButtonTheme.bar(
                      // make buttons use the appropriate styles for cards
                      child: ButtonBar(
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () {
                              gameState.startQuickPlay(GameMode.BINGO);
                            },
                            textColor: Colors.white,
                            child: Text("Quick Play"),
                          ),
                          RaisedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Setup(gameMode: GameMode.BINGO)),
                              );
                            },
                            textColor: Colors.white,
                            child: Text("New Game"),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
              child: RaisedButton(
                onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: Text("Patchwork"),
                          ),
                          body: SafeArea(child: HighscoreScreen()))),
                );
              },
              padding: EdgeInsets.all(0),
              color: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              textColor: Colors.white,
              child: Icon(Icons.access_alarm)
              ),
          ),
        ),
      ]),
    );
  }
}

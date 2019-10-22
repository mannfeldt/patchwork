import 'package:flutter/material.dart';
import 'package:patchwork/components/gameModeCard.dart';
import 'package:patchwork/logic/gamestate.dart';
import 'package:patchwork/pages/leaderboardScreen.dart';
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
                    colors: [Colors.purple, Colors.transparent],
                  ).createShader(Rect.fromLTRB(
                      0, rect.height * 0.8, rect.width, rect.height));
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/background2.jpg',
                  fit: BoxFit.contain,
                ))),
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
              child: Text(
                "Patchwork",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 8.0,
                        color: Color.fromARGB(125, 0, 0, 255),
                      ),
                    ],
                    color: Colors.white),
              ),
            ),
            GameModeCard(
              backgroundImage: "assets/classic_screenshot.gif",
              bakgroundVideo: "assets/classic_gameplay.gif",
              gameMode: GameMode.CLASSIC,
              title: "Classic",
              subtitle:
                  "Classic game of patchwork. Identical to the board game.",
              quickplayCallback: gameState.startQuickPlay,
            ),
            GameModeCard(
              backgroundImage: "assets/bingo_screenshot.gif",
              bakgroundVideo: "assets/bingo_gameplay.gif",
              gameMode: GameMode.BINGO,
              title: "Bingo",
              subtitle:
                  "Patchwork with a twist! For every line you complete in the same color you get extra loot.",
              quickplayCallback: gameState.startQuickPlay,
            ),
          ],
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8, right: 8),
            height: 40,
            width: 40,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              color: Colors.yellow.shade800.withOpacity(0.7),
              textColor: Colors.white,
              padding: EdgeInsets.all(0.0),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: Text("Leaderboard"),
                          ),
                          body: SafeArea(child: LeaderboardScreen()))),
                );
              },
              child: Icon(PatchworkIcons.award, color: Colors.yellow, size: 28),
              //behöver lösa priblem med compound path för att få in de finare ikonerna. patchworkicons.award_1
            ),
          ),
        )
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/utilities/patchwork_icons_icons.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/logic/gamestate.dart';
import 'package:showcaseview/showcaseview.dart';

class Footer extends StatelessWidget {
  final GlobalKey passKey;
  final GlobalKey cashKey;
  final GlobalKey nameKey;

  Footer({this.passKey, this.cashKey, this.nameKey});
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    Player currentPlayer = gameState.getCurrentPlayer();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Showcase(
            key: nameKey,
            textColor: Colors.white,
            showcaseBackgroundColor: buttonColor,
            title: "Player",
            description: 'Here you can see whos turn it is to play',
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: "buttonanimationemoji",
                    child: new Material(
                      color: Colors.transparent,
                      child: Text(
                        currentPlayer.emoji + " ",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  Hero(
                    tag: "buttonanimationname",
                    child: new Material(
                      color: Colors.transparent,
                      child: Text(
                        currentPlayer.name,
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            )),
        Showcase(
            key: cashKey,
            textColor: Colors.white,
            showcaseBackgroundColor: buttonColor,
            title: "Buttons",
            description: 'This is the amount of buttons you can spend',
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Hero(
                      tag: "buttonanimationscore",
                      child: new Material(
                        color: Colors.transparent,
                        child: Text(
                          currentPlayer.buttons.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    Hero(
                      tag: "buttonanimationscoreicon",
                      child: new Material(
                        color: Colors.transparent,
                        child: Icon(
                          PatchworkIcons.button_icon,
                          color: buttonColor,
                          size: 28,
                        ),
                      ),
                    ),
                  ]),
            )),
        Showcase(
            key: passKey,
            textColor: Colors.white,
            showcaseBackgroundColor: buttonColor,
            title: "Pass",
            description: 'Tap this to pass your turn',
            child: IconButton(
              icon: Icon(Icons.skip_next),
              tooltip: "pass",
              onPressed: () {
                if (gameState.getDraggedPiece() == null &&
                    gameState.getExtraPieceCollected() == false &&
                    gameState.getScissorsCollected() == false) {
                  gameState.pass();
                }
              },
            ))
      ],
    );
  }
}

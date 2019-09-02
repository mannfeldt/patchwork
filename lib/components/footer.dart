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
              child: Row(children: <Widget>[
                Icon(
                  currentPlayer.isAi ? Icons.android : Icons.person,
                  color: currentPlayer.color,
                  size: 28,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 0),
                  child: Text(
                    currentPlayer.name,
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ]),
            )),
        Showcase(
            key: cashKey,
            textColor: Colors.white,
            showcaseBackgroundColor: buttonColor,
            title: "Buttons",
            description: 'This is the amount of buttons you can spend',
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: <Widget>[
                Text(
                  currentPlayer.buttons.toString(),
                  style: TextStyle(fontSize: 20),
                ),
                Icon(
                  PatchworkIcons.button_icon,
                  color: buttonColor,
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

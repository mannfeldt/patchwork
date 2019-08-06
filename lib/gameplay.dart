import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/ruleEngine.dart';
import 'package:patchwork/gamestate.dart';

class Gameplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    //gameState.addPlayer();
    //gameState.setPieceMode();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  RuleEngine.generatePieces();
                },
                child: Text(
                    "Istället för dena knapp ska det vara en selectlist där man får välja antal spelare 2-4 (Color, name, isAi) om de ska vara AI ,vilken piecemode "),
              ),
              RaisedButton(
                onPressed: () {
                  print("start");
                },
                child: Text("GAMEPLAY THIS IS"),
              )
            ],
          )
        ],
      ),
    );
  }
}

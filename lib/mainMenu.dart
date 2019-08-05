import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/ruleEngine.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final gameState = Provider.of<GameState>(context);

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
                child: Text("Continue"),
              ),
              RaisedButton(
                onPressed: () {
                  print("new game");
                },
                child: Text("New game"),
              )
            ],
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:patchwork/components/highscoreTable.dart';
import 'package:patchwork/logic/gamestate.dart';
import 'package:patchwork/logic/sessionstate.dart';
import 'package:patchwork/pages/setup.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/utilities/patchwork_icons_icons.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Center(
      child: Column(children: <Widget>[
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                leading: Icon(PatchworkIcons.button_icon),
                title: Text('Classic'),
                subtitle: Text('Classic game.'),
              ),
              ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        gameState.startQuickPlay();
                      },
                      textColor: Colors.white,
                      child: Text("Quick Play"),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Setup(gameMode: GameMode.CLASSIC)),
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
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                leading: Icon(PatchworkIcons.button_icon),
                title: Text('BINGO!!!!!!'),
                subtitle: Text('Play bingo with everyone! For every line you complete in the same color you get extra loot.'),
              ),
              ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        gameState.startQuickBingoPlay();
                      },
                      textColor: Colors.white,
                      child: Text("Quick Play"),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Setup(gameMode: GameMode.BINGO)),
                        );
                      },
                      textColor: Colors.white,
                      child: Text("Play"),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        RaisedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text("Patchwork"),
                      ),
                      body: SafeArea(child: HighscoreTable()))),
            );
          },
          child: Text("Highscore"),
        )
      ]),
    );
  }
}

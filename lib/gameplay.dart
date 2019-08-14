import 'package:flutter/material.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/footer.dart';
import 'package:patchwork/gameBoard.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/patchSelector.dart';
import 'package:patchwork/timeGameBoard.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/gamestate.dart';

class Gameplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    Player currentPlayer = gameState.getCurrentPlayer();
// TODO se nedan

    // refactorisera. nya widgetar. flytta metoder till rule engine, util osv? lägg till constanter istället för hårdkodade värden

    //2. lägg till fler game mechanics. försten till 7x7. skriv bara ut en alert eller dialog ruta. skapa en generell ruta för händelser
    //3. skriv då att player x fick 7x7. sätt player.svenbysven = true och så räknas det i ruleEngine.countScore

    // jag har många ideet om gamemodes osv. vill inte lägg in allt i ett mode.
    //ska några modes eller ha standard och wild där man kan få välja av och på massa inställnignar?

    //hur hanterar jag detta bra i logiken? massa booleans och ifsatser? best practices kolla på.

    //koll min google keep efter de bästa kandidaterna till gamemodes / mechanics jag vill ha.

    //sax är coolt. bingo är lättare

    //kan best practice är att ha en enumlista med "gamemodes" och ha ifsatser/kollar där det behövs på om gamestate.hasGameMode("xx");

    return SafeArea(
      child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        // constraints variable has the size info
        double boardTileSize = gameState.getBoardTileSize();
        gameState.setConstraints(constraints.maxWidth, constraints.maxHeight);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(gameBoardInset,gameBoardInset,gameBoardInset,0),
                child: GameBoard(board: currentPlayer.board),
                height: constraints.maxWidth,
              ),
              Container(
                child: PatchSelector(),
                height: gameState.getPatchSelectorHeight(),
              ),
              Container(
                child: TimeGameBoard(),
                height: boardTileSize != null ? boardTileSize/1.2 : 0,
              ),
              Container(
                child: Footer(),
                height: boardTileSize ?? 0,
              )
            ],
          ),
        );
      }),
    );
  }
}

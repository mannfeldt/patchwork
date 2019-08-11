import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/footer.dart';
import 'package:patchwork/gameBoard.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/patchSelector.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/gamestate.dart';

class Gameplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    Player currentPlayer = gameState.getCurrentPlayer();
    gameState.setBoardTileSize(MediaQuery.of(context).size);
// TODO se nedan
  //  nästa grej. fixa spegling och rotering av pieces. finns färdiga funktioner i piece klassen. gäller att updatera state också?
  //  testa mig fram.toString()
  //  flip har jag men rotering som jag trodde jag hade får jag jobba vidare på ....

  //  sen lägg till fina ikoner för cost och time, buttons, playername ska ha en ikon istället för "PLAYER"
  //  fixa en riktig bild på en knapp eller något för att rendrera istället för "B" eller bara lägg en Circle där som patch har

  //   nästa steg efter det är att skapa timeboard vyn. och navigeringen till den? eller ha den som en smal lista under pieceselector?
  //eller till vänster om playerboard. eller till vänster om hela skärmen. börja med en bara. enkelt att ändra ju. det är ju bara en position och horizontal eller vertical

  //refactorisera. nya widgetar. flytta metoder till rule engine, util osv? lägg till constanter istället för hårdkodade värden

    return SafeArea(
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GameBoard(board: currentPlayer.board),
          PatchSelector(),
          Footer(),
        ],
      ),
    ));
  }
}

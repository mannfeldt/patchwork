import 'package:flutter/material.dart';
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
    gameState.setBoardTileSize(MediaQuery.of(context).size);
// TODO se nedan

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
          TimeGameBoard(),
          Footer(),
        ],
      ),
    ));
  }
}

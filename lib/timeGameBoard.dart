import 'package:flutter/material.dart';
import 'package:patchwork/TimeBoardTile.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/timeBoard.dart';
import 'package:patchwork/patch.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/gamestate.dart';

class TimeGameBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    Player currentPlayer = gameState.getCurrentPlayer();
    List<Player> players = gameState.getPlayers();
    TimeBoard timeBoard = gameState.getTimeBoard();
    return Container(
      decoration: BoxDecoration(color: Colors.black12),
      height: timeBoardTileHeight,
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: timeBoard.goalIndex+1,
          itemBuilder: (context, index) {
            if(currentPlayer.position > index) return Container();
            bool hasExtraPiece = timeBoard.pieceIndexes.contains(index);
            bool hasButton = timeBoard.buttonIndexes.contains(index);
            bool isGoalLine = timeBoard.goalIndex == index;
            bool isStartTile = index ==0;
            List<Player> positionedPlayers =
                players.where((p) => p.position == index).toList();
                if(index==0 && positionedPlayers.length>6){
                  positionedPlayers = [new Player(0, "", Colors.black87, false)];
                }
            return Container(
                height: patchUnitSize,
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    TimeBoardTile(
                        currentPlayer: currentPlayer,
                        players: positionedPlayers,
                        hasButton: hasButton,
                        isGoalLine: isGoalLine,
                        isStartTile: isStartTile,
                        hasPiece: hasExtraPiece),
                  ],
                ));
          }),
    );
  }
}

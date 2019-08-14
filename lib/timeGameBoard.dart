import 'package:flutter/material.dart';
import 'package:patchwork/timeBoardTile.dart';
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
    double tileSize = gameState.getBoardTileSize();
    return Container(
      decoration: BoxDecoration(color: Colors.black12),
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: timeBoard.goalIndex + 1,
          itemBuilder: (context, index) {
            if (currentPlayer.position > index) return Container();
            bool hasExtraPiece = timeBoard.pieceIndexes.contains(index);
            bool hasButton = timeBoard.buttonIndexes.contains(index);
            bool isGoalLine = timeBoard.goalIndex == index;
            bool isStartTile = index == 0;
            List<Player> positionedPlayers =
                players.where((p) => p.position == index).toList();
            bool isCrowded = positionedPlayers.length > 3;
            return Container(
              height: tileSize,
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                  border: new Border.all(
                      color: Colors.black87, width: boardTilePadding)),
              child: TimeBoardTile(
                  currentPlayer: currentPlayer,
                  players: positionedPlayers,
                  hasButton: hasButton,
                  isGoalLine: isGoalLine,
                  isStartTile: isStartTile,
                  tileWidth: tileSize * 1.5,
                  isCrowded: isCrowded,
                  hasPiece: hasExtraPiece),
            );
          }),
    );
  }
}

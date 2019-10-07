import 'package:flutter/material.dart';
import 'package:patchwork/components/timeBoardTile.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/timeBoard.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/logic/gamestate.dart';

class TimeGameBoard extends StatefulWidget {
  @override
  _TimeGameBoardState createState() => _TimeGameBoardState();
}

class _TimeGameBoardState extends State<TimeGameBoard> {
  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    Player currentPlayer = gameState.getCurrentPlayer();
    List<Player> players = gameState.getPlayers();
    TimeBoard timeBoard = gameState.getTimeBoard();
    double tileSize = gameState.getBoardTileSize() * 1.5;
    double scrollPos = ((boardTilePadding * 2) * currentPlayer.position) +
        (currentPlayer.position * tileSize);
    if (currentPlayer.position > 0) scrollPos += tileSize;

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await _scrollController.animateTo(
    //     (scrollPos),
    //     curve: Curves.easeIn,
    //     duration: const Duration(milliseconds: 400),
    //   );
    // });

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          itemCount: timeBoard.goalIndex + 1,
          itemBuilder: (context, index) {
            bool hasExtraPiece = timeBoard.pieceIndexes.contains(index);
            bool hasScissors = timeBoard.scissorsIndexes.contains(index);
            bool hasButton = timeBoard.buttonIndexes.contains(index);
            bool isGoalLine = timeBoard.goalIndex == index;
            bool isStartTile = index == 0;
            List<Player> positionedPlayers =
                players.where((p) => p.position == index).toList();
            bool isCrowded = positionedPlayers.length > 2;
            return Container(
              height: tileSize / 1.5,
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                  border: new Border.all(
                      color: Colors.black26, width: boardTilePadding)),
              child: TimeBoardTile(
                  currentPlayer: currentPlayer,
                  players: positionedPlayers,
                  index: index,
                  hasButton: hasButton,
                  isGoalLine: isGoalLine,
                  isStartTile: isStartTile,
                  tileWidth: tileSize,
                  isCrowded: isCrowded,
                  hasScissors: hasScissors,
                  hasPiece: hasExtraPiece),
            );
          }),
    );
  }
}

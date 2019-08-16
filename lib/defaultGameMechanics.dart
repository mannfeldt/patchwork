import 'dart:math';
import 'package:patchwork/gamestate.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/models/timeBoard.dart';
import 'package:patchwork/pieceGenerator.dart';
import 'package:patchwork/patchworkRuleEngine.dart';
import 'package:patchwork/utils.dart';

class DefaultGameMechanics implements PatchworkRuleEngine {
  @override
  bool isGameFinished(List<Player> players) {
    return players.every((p) => p.state == "finished");
  }

  @override
  int calculateScore(Player player) {
    int missingTiles =
        (player.board.cols * player.board.rows) - player.board.squares.length;
    int score = player.buttons - (missingTiles * 2);
    if(player.hasSevenBySeven) score += 7;
    return score;
  }

  @override
  bool canSelectPiece(Piece piece, Player player) {
    if (piece.cost > player.buttons) return false;
    return true;
  }

  @override
  List<Piece> generatePieces(int noOfPlayers) {
    List<Piece> pieces = [];
    int stacksOfPieces = (noOfPlayers / 2).round();
    for (int i = 0; i < stacksOfPieces; i++) {
      pieces.addAll(PieceGenerator.getDefaultPieces());
    }
    pieces.shuffle();
    return pieces;
  }

  @override
  Player getNextPlayer(List<Player> players, Player currentPlayer) {
    int lastPosition =
        players.reduce((a, b) => a.position < b.position ? a : b).position;
    List<Player> lastPlayers =
        players.where((p) => p.position == lastPosition).toList();
    if (lastPlayers.length > 1 && lastPlayers.contains(currentPlayer))
      return currentPlayer;
    return lastPlayers[0];
  }

  @override
  bool validatePlacement(List<Square> placement, Board board) {
    bool isOutOfBounds = Utils.isOutOfBoardBounds(placement, board);
    if (isOutOfBounds) return false;

    bool fitsOnBoard = Utils.hasRoom(placement, board);
    return fitsOnBoard;
  }

  @override
  TimeBoard initTimeBoard() {
    return new TimeBoard();
  }

  @override
  List<Player> initPlayers(List<Player> players) {
    return players;
  }

  @override
  void endOfTurn(GameState gameState) {
    Player currentPlayer = gameState.getCurrentPlayer();
    List<Player> players = gameState.getPlayers();
    bool hasSevenBySeven = players.any((p) => p.hasSevenBySeven);
    if (!hasSevenBySeven) {
      //hämta detta från en konstant istället?
      List<Square> initialShape = [];
      for (int x = 0; x < 7; x++) {
        for (int y = 0; y < 7; y++) {
          Square s = new Square.simple(x, y);
          initialShape.add(s);
        }
      }
      currentPlayer.hasSevenBySeven =
          Utils.hasPattern(initialShape, currentPlayer.board);
    }
  }
}

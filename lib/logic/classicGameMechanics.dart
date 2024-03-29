import 'package:patchwork/logic/gamestate.dart';
import 'package:patchwork/models/announcement.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/score.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/timeBoard.dart';
import 'package:patchwork/utilities/pieceGenerator.dart';
import 'package:patchwork/logic/patchworkRuleEngine.dart';
import 'package:patchwork/utilities/utils.dart';

class ClassicGameMechanics implements PatchworkRuleEngine {
  @override
  bool isGameFinished(List<Player> players) {
    return players.every((p) => p.state == "finished");
  }

  @override
  Score calculateScore(Player player) {
    int plus = player.buttons;
    int minus = Utils.emptyBoardSpaces(player.board) * 2;
    int extra = player.hasSevenBySeven ? 7 : 0;
    Score score = new Score(plus, minus, extra);
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
      pieces.addAll(PieceGenerator.getClassicPieces());
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
      List<Square> sevenBySeven = [];
      for (int x = 0; x < 7; x++) {
        for (int y = 0; y < 7; y++) {
          Square s = new Square.simple(x, y);
          sevenBySeven.add(s);
        }
      }
      bool hasSevenBySeven =
          Utils.hasPattern(sevenBySeven, currentPlayer.board);
      if (hasSevenBySeven) {
        currentPlayer.hasSevenBySeven = true;
        gameState.makeAnnouncement(
            "7x7 found",
            currentPlayer.name +
                " will recieve 7 points at the end of the game",
            AnnouncementType.dialog);
      }
    }
  }

  @override
  bool piecePlaced(GameState gameState) {
    return false;
  }
}

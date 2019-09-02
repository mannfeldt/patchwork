import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/logic/gamestate.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/models/timeBoard.dart';
import 'package:patchwork/utilities/pieceGenerator.dart';
import 'package:patchwork/logic/patchworkRuleEngine.dart';
import 'package:patchwork/utilities/utils.dart';

class BingoGameMechanics implements PatchworkRuleEngine {
  @override
  bool isGameFinished(List<Player> players) {
    return players.every((p) => p.state == "finished");
  }

  @override
  int calculateScore(Player player) {
    int missingTiles = Utils.emptyBoardSpaces(player.board);
    int score = player.buttons - (missingTiles * 2);
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
      pieces.addAll(PieceGenerator.getBingoModePieces(40));
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
    return new TimeBoard.bingo();
  }

  @override
  List<Player> initPlayers(List<Player> players) {
    players.forEach((p) => p.buttons = bingoStartButtons);
    players.forEach((p) => p.board.cols = 8);

    return players;
  }

  @override
  bool piecePlaced(GameState gameState) {
    Player currentPlayer = gameState.getCurrentPlayer();
    List<int> bingos = Utils.getBingoRows(currentPlayer.board);
    List<int> newBingos =
        bingos.where((b) => !currentPlayer.bingos.contains(b)).toList();
    if (newBingos.length > 0) {
      gameState.handleBingo(newBingos);
      return true;
    }
    return false;
  }

  @override
  void endOfTurn(GameState gameState) {}
}

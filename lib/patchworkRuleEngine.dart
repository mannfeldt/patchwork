import 'package:patchwork/gamestate.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/models/timeBoard.dart';

abstract class PatchworkRuleEngine {
  bool isGameFinished(List<Player> players);
  List<Piece> generatePieces(int noOfPlayers);

  bool canSelectPiece(Piece piece, Player player);
  Player getNextPlayer(List<Player> players, Player currentPlayer);
  int calculateScore(Player player);
  TimeBoard initTimeBoard();
  List<Player> initPlayers(List<Player> players);
  bool validatePlacement(List<Square> placement, Board board);
  void endOfTurn(GameState gameState);
}

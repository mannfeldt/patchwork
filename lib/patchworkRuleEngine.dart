import 'dart:math';
import 'package:patchwork/gamestate.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/models/timeBoard.dart';
import 'package:patchwork/pieceGenerator.dart';
import 'package:patchwork/utils.dart';

abstract class PatchworkRuleEngine {
  bool isGameFinished(List<Player> players);
  List<Piece> generatePieces(int noOfPlayers);
  bool validatePlacement(Piece piece, Board board, int x,
      int y); // kan ha olika ideer om vad som är valid

  bool canSelectPiece(Piece piece, Player player);
  Player getNextPlayer(List<Player> players, Player currentPlayer);
  int calculateScore(Player player);
  TimeBoard initTimeBoard();
  List<Player> initPlayers(List<Player> players);
  void test(GameState test);
}

import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/square.dart';

class Board {
  int buttons;
  List<Piece> pieces;
  List<Square> squares;
  Player player;
  int rows;
  int cols;

  Board(Player player) {
    this.buttons = 0;
    this.rows = 9;
    this.cols = 9;
    this.pieces = [];
    this.squares = [];
    this.player = player;
  }
  void addPiece(Piece piece) {
    piece.shape.forEach((s) => s.filled = true);
    this.pieces.add(piece);
    //viktigt att inte få dubletter till squares
    for (Square square in piece.shape) {
      bool exists = this.squares.any((s) => s.x == square.x && s.y == square.y);
      if (!exists) {
        this.squares.add(square);
      }
    }

    this.buttons += piece.buttons;
  }
}

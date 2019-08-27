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
      bool exists = this.squares.any((s) => s.samePositionAs(square));
      if (!exists) {
        this.squares.add(square);
      }
    }

    this.buttons += piece.buttons;
    placeStitches();
  }

  void cutSquare(Square square) {
    //loppa alla square och ta bort den
    //behöver jag ta bort den från piece.shape?
    this.squares.removeWhere((s) => s.samePositionAs(square));
    for (int i = 0; i < pieces.length; i++) {
      Piece p = pieces[i];
      List<Square> shape = p.shape;
      int shapeLen = shape.length;
      for (int j = 0; j < shapeLen; j++) {
        Square s = shape[j];
        if (s.samePositionAs(square)) {
          if (s.hasButton) buttons -= 1;
          shape.remove(s);
          break;
        }
      }
    }
    player.bingos.removeWhere((b) => b == square.y);
    placeStitches();
  }

  void placeStitches() {
    for (int i = 0; i < pieces.length; i++) {
      Piece p = pieces[i];
      List<Square> shape = p.shape;
      List<Square> otherSquares =
          squares.where((s) => !shape.contains(s)).toList();
      for (Square s in shape) {
        s.leftStitching = false;
        s.topStitching = false;
        Square left = new Square.simple(s.x - 1, s.y);
        Square top = new Square.simple(s.x, s.y - 1);
        for (Square other in otherSquares) {
          if (other.samePositionAs(left)) {
            s.leftStitching = true;
          }
          if (other.samePositionAs(top)) {
            s.topStitching = true;
          }
        }
      }
    }
  }
}

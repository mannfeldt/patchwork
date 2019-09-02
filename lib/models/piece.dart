import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/models/square.dart';

class Piece {
  int id;
  int buttons;
  List<Square> shape;
  int cost;
  int time;
  int costAdjustment;
  Square anchorPosition;
  bool selectable;
  Square
      boardPosition; // leftTopMostposition that the piece is located on the board
  int difficulty;
  String state; // active, selectable, unselectable, used
  String imgSrc;

  Piece(int id, List<Square> shape, int buttons, int cost, int time, int costAdjustment, String imgSrc) {
    this.id = id;
    this.shape = shape;
    this.state = "active";
    this.buttons = buttons;
    this.cost = cost;
    this.time = time;
    this.costAdjustment = costAdjustment;
    this.selectable = false;
    this.imgSrc = imgSrc;
  }

  Piece.single(int id) {
    this.id = id;
    Square s = new Square(0, 0, true, singlePiece);
    this.shape = [s];
    this.state = "active";
    this.buttons = 0;
    this.cost = 0;
    this.time = 0;
    this.costAdjustment = 0;
    this.selectable = true;
    this.imgSrc = singlePiece;
  }

  List<String> getVisual() {
    List<String> s = [
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]"
    ];

    for (int i = 0; i < shape.length; i++) {
      String row = s[shape[i].y];
      Square square = shape[i];
      int startIndex = 1 + (square.x * 3);
      final replaced = row.replaceFirst(
          RegExp(' '), square.hasButton ? 'B' : 'X', startIndex);
      //row = replaced;
      s[square.y] = replaced;
    }
    for (int i = 0; i < s.length; i++) {
      s[i] = s[i].replaceAll(RegExp('\\[ \\]'), "   ");
    }

    return s;
  }

  void log() {
    List<String> s = getVisual();
    for (int i = 0; i < s.length; i++) {
      if (s[i].trim().length > 0) {
        print(s[i]);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:patchwork/models/square.dart';

class Piece {
  int id;
  int size;
  int buttons;
  List<Square> shape;
  int cost;
  int time;
  int costAdjustment;
  Color color;
  Square anchorPosition;
  bool selectable;
  Square
      boardPosition; // leftTopMostposition that the piece is located on the board
  int difficulty;
  String state; // active, selectable, unselectable, used
  int version;

  Piece(int id, List<Square> shape, int buttons, int cost, int time,
      Color color, int costAdjustment) {
    this.id = id;
    this.shape = shape;
    this.state = "active";
    this.size = shape.length;
    this.buttons = buttons;
    this.cost = cost;
    this.time = time;
    this.color = color;
    this.costAdjustment = costAdjustment;
    this.selectable = false;
    this.version = 0;
  }

  Piece.single(int id) {
    this.id = id;
    Square s = new Square(0, 0, true);
    s.color = Colors.brown;
    this.shape = [s];
    this.state = "active";
    this.size = shape.length;
    this.buttons = 0;
    this.cost = 0;
    this.time = 0;
    this.color = Colors.brown;
    this.costAdjustment = 0;
    this.selectable = true;
    this.version = 0;
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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/constants.dart';

class Piece {
  int id;
  int size;
  int buttons;
  List<Square> shape;
  int cost;
  int time;
  Color color;
  int difficulty;
  String costAdjustment; // 10SALE, 20SALE, 30SALE, 10OVER, 20OVER, 30OVER
  String state; // active, selectable, unselectable, used

  Piece.fromVisual(int id, List<String> visual) {
    this.id = id;
    this.state = "active";
    this.shape = _getShapeFromVisual(visual);
    this.size = shape.length;
    this.buttons = _getButtons(this.size);
    this.difficulty = _getDificulty(this.shape);
    this.color = _getColor();
    _placeButtons();
    _setCost();
  }

  Piece(int id, List<String> visual, int buttons, int cost, int time) {
    this.id = id;
    this.shape = _getShapeFromVisual(visual);
    this.state = "active";
    this.size = shape.length;
    this.buttons = buttons;
    this.cost = cost;
    this.time = time;
    this.costAdjustment = "NONE";
    this.difficulty = _getDificulty(this.shape);
    this.color = _getColor();
    _placeButtons();
  }

  Piece.random(int id) {
    this.id = id;
    this.state = "active";
    this.size = _getSize();
    this.shape = _getShape(this.size);
    this.buttons = _getButtons(this.size);
    this.difficulty = _getDificulty(this.shape);
    this.color = _getColor();
    _placeButtons();
    _setCost();
  }

  Color _getColor() {
    var rng = new Random();
    int colorIndex = rng.nextInt(Constants.pieceColors.length);
    Color color = Constants.pieceColors[colorIndex];
    return color;
  }

  int _getSize() {
    //skulle kunna ta in befintliga peices och avgöra chanserna lite baserat på det.
    //alltså om det är ett högt medel på befntliga så lutar vi mer åt att skapa en lägre och lika åt andra hållet
    var rng = new Random();
    int num = rng.nextInt(100);
    if (num < 5) return 2;
    if (num < 5 + 9) return 3;
    if (num < 14 + 12) return 4;
    if (num < 26 + 13) return 5;
    if (num < 39 + 14) return 6;
    if (num < 53 + 14) return 7;
    if (num < 67 + 12) return 8;
    if (num < 79 + 9) return 9;
    if (num < 87 + 7) return 10;
    if (num < 94 + 5) return 11;
    return 12;
  }

  int _getButtons(int size) {
    var rng = new Random();
    int num = rng.nextInt(100);
    int max = size - 2; //behöver två rutor för att skriva ut kostnaden
    if (num < 33) return 0;
    if (num < 33 + 25) return 1;
    if (num < 58 + 20) return min(max, 2);
    if (num < 78 + 15) return min(max, 3);
    return min(max, 4);
  }

  List<Square> _cropPiece(List<Square> shape) {
    int minY = shape.reduce((a, b) => a.y < b.y ? a : b).y;
    int minX = shape.reduce((a, b) => a.x < b.x ? a : b).x;

    List<Square> croppedShape = [];
    croppedShape.addAll(shape);

    while (minY > 0) {
      croppedShape = croppedShape.map((s) => new Square(s.x, s.y - 1)).toList();
      minY = croppedShape.reduce((a, b) => a.y < b.y ? a : b).y;
    }
    while (minX > 0) {
      croppedShape = croppedShape.map((s) => new Square(s.x - 1, s.y)).toList();
      minX = croppedShape.reduce((a, b) => a.x < b.x ? a : b).x;
    }
    return croppedShape;
  }

  int _getDificulty(List<Square> shape) {
    List<Square> searchable = [];
    List<Square> actual =
        shape.map((s) => new Square(s.x + 1, s.y + 1)).toList();

    int maxY = actual.reduce((a, b) => a.y > b.y ? a : b).y;
    int maxX = actual.reduce((a, b) => a.x > b.x ? a : b).x;
    int minY = actual.reduce((a, b) => a.y < b.y ? a : b).y;
    int minX = actual.reduce((a, b) => a.x < b.x ? a : b).x;

    for (int curY = 0; curY < maxY + 2; curY++) {
      for (int curX = 0; curX < maxX + 2; curX++) {
        Square s = new Square(curX, curY);
        searchable.add(s);
      }
    }

    int difficulty = 0;
    List<Square> multipleNeighbors = [];
    for (int i = 0; i < searchable.length; i++) {
      Square square = searchable[i];
      bool exists = actual.any((s) => s.y == square.y && s.x == square.x);
      if (!exists) {
        int neighbors = _countNeighbors(square, actual);

        if (neighbors == 1) difficulty += 1;
        if (neighbors == 2) difficulty += (6 + shape.length / 3).round();
        if (neighbors == 3) difficulty += (10 + shape.length / 3).round();
        if (neighbors == 4) difficulty += (22 + shape.length / 3).round();

        if (neighbors > 1) {
          multipleNeighbors.add(square);
        }
      }
    }
    //check for stairs or other extreme occorances
    for (int i = 0; i < multipleNeighbors.length; i++) {
      Square current = multipleNeighbors[i];
      bool hasNorthWest = multipleNeighbors
          .any((s) => s.x == current.x - 1 && s.y == current.y - 1);
      bool hasNorthEast = multipleNeighbors
          .any((s) => s.x == current.x + 1 && s.y == current.y - 1);
      if (hasNorthEast) difficulty += 22;
      if (hasNorthWest) difficulty += 22;
    }
    difficulty += multipleNeighbors.length * 2;

    if (shape.length > 4) {
      int spreadRatio = (maxX - minX) * (maxY - minY);
      int sizeToSpreadRatio = spreadRatio - (shape.length - 2);
      int spreadExtra = (spreadRatio + (min(2, sizeToSpreadRatio))) * 2;
      difficulty += min(25, spreadExtra);
      if (((spreadRatio + sizeToSpreadRatio) * 2) < 0) {
        //har så blir spread till att sänka deiff. är det bra? kolla vilka som kan hamnar här och vad som händer med dem. väldigt få fall
      }

      //print("SPREAD " + spreadRatio.toString());
    }

    return difficulty - 4;
  }

  void _placeButtons() {
    Random rng = new Random();
    int buttonsPlaces = this.shape.where((s) => s.hasButton).length;
    while (this.buttons > buttonsPlaces) {
      int squareIndex = rng.nextInt(this.shape.length);
      this.shape[squareIndex].hasButton = true;
      buttonsPlaces = this.shape.where((s) => s.hasButton).length;
    }
  }

  int _countNeighbors(Square square, List<Square> possibleNeighbors) {
    int neighbors = 0;
    for (int i = 0; i < possibleNeighbors.length; i++) {
      Square possibleNeighbor = possibleNeighbors[i];
      for (Square direction in Constants.directions) {
        if (possibleNeighbor.y == (square.y + direction.y) &&
            possibleNeighbor.x == (square.x + direction.x)) {
          neighbors += 1;
        }
      }
    }
    return neighbors;
  }

  List<Square> _getShape(int size) {
    List<Square> shape = [];

    var rng = new Random();
    int startX = rng.nextInt(7);
    int startY = rng.nextInt(7);
    Square startSquare = new Square(startX, startY);
    shape.add(startSquare);
    while (shape.length < size) {
      Square latest = shape[shape.length - 1];
      Square direction = Constants.directions[rng.nextInt(4)];
      Square newSquare =
          new Square(latest.x + direction.x, latest.y + direction.y);
      if (_outOfBounds(newSquare)) {
        continue;
      }
      shape.removeWhere((s) => s.x == newSquare.x && s.y == newSquare.y);
      shape.add(newSquare);
    }
    return _cropPiece(shape);
  }

  bool validate() {
    //några specifika mönster jag inte vill ha? ha en lista i util
  }

  void _setCost() {
    int buttonFactor = (this.buttons * 4);
    int sizeFactor = (this.shape.length * 1.2).floor() + 1;
    int diffFactor = (this.difficulty / 9).round();
    int totalCost = buttonFactor + sizeFactor - diffFactor;

    if (shape.length == 3) {
      totalCost = max(4, totalCost); //0-10 eller 15 kanske
    } else {
      totalCost = max(3, totalCost); //0-10 eller 15 kanske
    }

    Random rng = new Random();
    int num = rng.nextInt(100);
    this.costAdjustment = "NONE";
    if (num < 3)
      this.costAdjustment = "SALE30";
    else if (num < 3 + 4)
      this.costAdjustment = "SALE20";
    else if (num < 8 + 6)
      this.costAdjustment = "SALE10";
    else if (num < 15 + 5)
      this.costAdjustment = "OVER10";
    else if (num < 21 + 3)
      this.costAdjustment = "OVER20";
    else if (num < 25 + 2) this.costAdjustment = "OVER30";
    double adjustmentRate = Constants.costAdjustments[this.costAdjustment];
    int extraButtons = (totalCost * adjustmentRate).floor();
    int maxRng = this.costAdjustment == "NONE" ? 100 : 80;
    int costDivide = rng.nextInt(maxRng);
    int timeExcp = (totalCost * (costDivide / 100)).round();
    this.time = min(10, timeExcp);
    this.cost = totalCost - this.time;
    print(this.costAdjustment + ": " + extraButtons.toString());
    this.cost += extraButtons;
    this.cost = max(0, this.cost);
  }

  bool _outOfBounds(Square square) {
    int min = 0;
    int max = 6;
    return square.x < min || square.x > max || square.y < min || square.y > max;
  }

  void rotatePiece() {
    //placera om coordinater för squares.
  }
  void flipPiece() {
    //positionera om squares
  }

  List<String> getVisual() {
    return _getVisual(this.shape);
  }

  List<Square> _getShapeFromVisual(List<String> visual) {
    List<Square> shape = [];
    for (int y = 0; y < visual.length; y++) {
      for (int x = 0; x < visual[y].length; x++) {
        String char = visual[y].substring(x, x + 1);
        if (char == "X") {
          int realX = ((x - 1) / 3).round();
          Square s = new Square(realX, y);
          shape.add(s);
        }
      }
    }
    return shape;
  }

  List<String> _getVisual(List<Square> shape) {
    //retunera en visual presentation av squares
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

  void render(List<String> s) {
    for (int i = 0; i < s.length; i++) {
      if (s[i].trim().length > 0) {
        print(s[i]);
      }
    }
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/utilities/utils.dart';

class PieceGenerator {
  static List<Piece> getDefaultPieces() {
    List<Piece> pieces = [];
    for (int i = 0; i < defaultPieces.length; i++) {
      var piece = defaultPieces[i];
      int buttons = piece['buttons'];
      int cost = piece['cost'];
      int time = piece['time'];
      String imgName = _getImgName();
      List<Square> shape = _getShapeFromVisual(piece['visual'], imgName);
      shape = _placeButtons(shape, buttons);

      int id = pieces.length;
      Piece p = new Piece(id, shape, buttons, cost, time, imgName);
      pieces.add(p);
    }
    return pieces;
  }

  static List<Piece> getBingoModePieces(int amount) {
    List<String> imageSelection = [];
    Random rng = new Random();
    while (imageSelection.length <
        min(bingoModeNrOfDifferentImages, pieceImages.length)) {
      String img = pieceImages[rng.nextInt(pieceImages.length)];
      if (!imageSelection.contains(img)) {
        imageSelection.add(img);
      }
    }

    List<Piece> pieces = [];
    while (pieces.length < amount) {
      int id = pieces.length;
      int size = _getSize();
      int buttons = _getButtons(size);
      Color color = _getColor();
      String imgName = imageSelection[rng.nextInt(imageSelection.length)];
      List<Square> shape =
          _placeButtons(_getShape(size, color, imgName), buttons);
      int difficulty = _getDifficulty(shape);
      int totalValue = _getTotalValue(buttons, size, difficulty);
      totalValue -= buttons;
      int time = _getTimePart(totalValue);
      int cost = totalValue - time;
      Piece p = new Piece(id, shape, buttons, cost, time, imgName);
      int num = rng.nextInt(difficulty);
      if (num < 20 + (difficulty / 4)) {
        pieces.add(p);
      }
    }
    return pieces;
  }

  static List<Piece> getRandomPieces(int amount) {
    List<Piece> pieces = [];
    while (pieces.length < amount) {
      int id = pieces.length;
      int size = _getSize();
      int buttons = _getButtons(size);
      Color color = _getColor();
      String imgName = _getImgName();
      List<Square> shape =
          _placeButtons(_getShape(size, color, imgName), buttons);
      int difficulty = _getDifficulty(shape);

      int totalValue = _getTotalValue(buttons, size, difficulty);
      int time = _getTimePart(totalValue);
      int cost = totalValue - time;
      Piece p = new Piece(id, shape, buttons, cost, time, imgName);
      pieces.add(p);
    }
    return pieces;
  }

  static String _getImgName() {
    Random rng = new Random();
    String img = pieceImages[rng.nextInt(pieceImages.length)];
    return img;
  }

  static int _getTimePart(int totalValue) {
    Random rng = new Random();
    int chance = rng.nextInt(2);
    int costDivide = rng.nextInt(chance == 0 ? 70 : 100);
    int timeExcp = (totalValue * (costDivide / 100)).round();
    int time = min(10, timeExcp);
    return time;
  }

  static Color _getColor() {
    var rng = new Random();
    int colorIndex = rng.nextInt(pieceColors.length);
    Color color = pieceColors[colorIndex];
    return color;
  }

  static int _getSize() {
    var rng = new Random();
    int num = rng.nextInt(100);
    if (num < 8) return 2;
    if (num < 8 + 13) return 3;
    if (num < 21 + 19) return 4;
    if (num < 40 + 17) return 5;
    if (num < 57 + 15) return 6;
    if (num < 72 + 12) return 7;
    if (num < 84 + 9) return 8;
    if (num < 93 + 5) return 9;
    return 10;
  }

  static int _getButtons(int size) {
    var rng = new Random();
    int num = rng.nextInt(100);
    int max = size - 2;
    if (num < 38) return 0;
    if (num < 38 + 28) return 1;
    if (num < 66 + 21) return min(max, 2);
    if (num < 87 + 11) return min(max, 3);
    return min(max, 4);
  }

  static int _getDifficulty(List<Square> shape) {
    List<Square> searchable = [];
    List<Square> actual =
        shape.map((s) => new Square.simple(s.x + 1, s.y + 1)).toList();

    int maxY = actual.reduce((a, b) => a.y > b.y ? a : b).y;
    int maxX = actual.reduce((a, b) => a.x > b.x ? a : b).x;
    int minY = actual.reduce((a, b) => a.y < b.y ? a : b).y;
    int minX = actual.reduce((a, b) => a.x < b.x ? a : b).x;

    for (int curY = 0; curY < maxY + 2; curY++) {
      for (int curX = 0; curX < maxX + 2; curX++) {
        Square s = new Square.simple(curX, curY);
        searchable.add(s);
      }
    }

    int difficulty = 0;
    List<Square> multipleNeighbors = [];
    for (int i = 0; i < searchable.length; i++) {
      Square square = searchable[i];
      bool exists = actual.any((s) => s.samePositionAs(square));
      if (!exists) {
        int neighbors = _countNeighbors(square, actual);

        if (neighbors == 1) difficulty += 1;
        if (neighbors == 2) difficulty += (5 + shape.length / 3).round();
        if (neighbors == 3) difficulty += (10 + shape.length / 3).round();
        if (neighbors == 4) difficulty += (46 + shape.length / 3).round();

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
      if (hasNorthEast) difficulty += 23;
      if (hasNorthWest) difficulty += 23;
    }
    if (multipleNeighbors.length > 2) {
      difficulty += multipleNeighbors.length * 3;
    }

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

  static int _countNeighbors(Square square, List<Square> possibleNeighbors) {
    int neighbors = 0;
    for (int i = 0; i < possibleNeighbors.length; i++) {
      Square possibleNeighbor = possibleNeighbors[i];
      for (Square direction in directions) {
        if (possibleNeighbor.y == (square.y + direction.y) &&
            possibleNeighbor.x == (square.x + direction.x)) {
          neighbors += 1;
        }
      }
    }
    return neighbors;
  }

  static List<Square> _getShape(int size, Color color, String imgSrc) {
    List<Square> shape = [];

    var rng = new Random();
    int startX = rng.nextInt(maxPieceLength - 1);
    int startY = rng.nextInt(maxPieceLength - 1);
    Square startSquare = new Square.simple(startX, startY);
    startSquare.imgSrc = imgSrc;
    shape.add(startSquare);
    int lopps = 0;
    while (shape.length < size) {
      if (lopps > 100) {
        print("error");
      }
      lopps++;
      Square latest = shape[shape.length - 1];
      Square direction = directions[rng.nextInt(4)];
      Square newSquare =
          new Square.simple(latest.x + direction.x, latest.y + direction.y);
      if (_outOfBounds(newSquare)) {
        continue;
      }
      shape.removeWhere((s) => s.samePositionAs(newSquare));
      newSquare.imgSrc = imgSrc;
      shape.add(newSquare);
    }
    return Utils.cropPiece(shape);
  }

  bool validate() {
    //några specifika mönster jag inte vill ha? ha en lista i util
  }

  static int _getTotalValue(int buttons, int size, int difficulty) {
    int buttonFactor = buttons * 4;
    int sizeFactor = (size * 1.2).floor() + 1;
    int diffFactor = (difficulty / 9).round();
    int totalCost = buttonFactor + sizeFactor - diffFactor;
    if (size == 3) {
      totalCost = max(4, totalCost); //0-10 eller 15 kanske
    } else {
      totalCost = max(3, totalCost); //0-10 eller 15 kanske
    }
    return totalCost;
  }

  static bool _outOfBounds(Square square) {
    int min = 0;
    int max = maxPieceLength - 1;
    return square.x < min || square.x > max || square.y < min || square.y > max;
  }

  static List<Square> _placeButtons(List<Square> shape, int buttons) {
    Random rng = new Random();
    int buttonsPlaces = shape.where((s) => s.hasButton).length;
    while (buttons > buttonsPlaces) {
      int squareIndex = rng.nextInt(shape.length);
      shape[squareIndex].hasButton = true;
      buttonsPlaces = shape.where((s) => s.hasButton).length;
    }
    return shape;
  }

  static List<Square> _getShapeFromVisual(List<String> visual, String imgName) {
    List<Square> shape = [];
    for (int y = 0; y < visual.length; y++) {
      for (int x = 0; x < visual[y].length; x++) {
        String char = visual[y].substring(x, x + 1);
        if (char == "X") {
          int realX = ((x - 1) / 3).round();
          Square s = new Square.simple(realX, y);
          s.imgSrc = imgName;
          shape.add(s);
        }
      }
    }

    return shape;
  }
}

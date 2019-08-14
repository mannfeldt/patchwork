import 'package:flutter/material.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/square.dart';

class Utils {
  static bool hasRoom(List<Square> placement, Board board) {
    for (int i = 0; i < board.squares.length; i++) {
      Square inUse = board.squares[i];
      bool occupied = placement.any((s) => s.x == inUse.x && s.y == inUse.y);
      if (occupied) {
        return false;
      }
    }
    return true;
  }

  static bool isOutOfBoardBounds(List<Square> placement, Board board) {
    bool outOfBounds = placement.any(
        (s) => s.x < 0 || s.y < 0 || s.x >= board.cols || s.y >= board.rows);
    return outOfBounds;
  }

  static bool isFilled(List<Square> placement, Board board) {
    for (int i = 0; i < placement.length; i++) {
      Square square = placement[i];
      bool isUsed =
          board.squares.any((s) => s.x == square.x && s.y == square.y);
      if (!isUsed) return false;
    }
    return true;
  }

  static bool hasPattern(List<Square> pattern, Board board) {
    //kollat om ett mönster finns på en board. t.ex. 7x7 biten
    //börjar kolla om mönstret finns på ordinaeria plats och sedan flyttar pattern ett steg till höger tills det slår kanten
    //då flyttar mönsretet ner en rad och börjar kolla om det finns någon match på den raden fram tills att hela boardet har kollats
    //OBS kollar inte roterade mönster
    int maxY = pattern.reduce((a, b) => a.y > b.y ? a : b).y;
    int maxX = pattern.reduce((a, b) => a.x > b.x ? a : b).x;

    for (int x = 0; x < board.cols - maxX; x++) {
      for (int y = 0; y < board.rows - maxY; y++) {
        pattern.forEach((s) {
          s.x += x;
          s.y += y;
        });
        if (isFilled(pattern, board)) {
          return true;
        }
      }
    }
    return false;

    //om man har lika många y positions av samma värde som board.cols så har man en bingo vågrätt
    //om man har lika många x positions av samma värde som board.rows så har man en bingo lodrätt
  }

  static bool isBoardComplete(Board board) {
    bool complete = board.squares.length == board.cols * board.rows;
    return complete;
  }

  static bool hasBingo(Board board) {
    for (Color color in pieceColors) {
      List<Square> coloredSquares =
          board.squares.where((s) => s.color == color).toList();
      List<int> yPositions = coloredSquares.map((s) => s.y).toList();
      for (int i = 0; i < board.cols; i++) {
        if (board.cols == yPositions.where((x) => x == i).toList().length) {
          //det finns 9 olika squares i samma färg och ligger på samma rad. vågrätt bingo
          return true;
        }
      }
      List<int> xPositions = coloredSquares.map((s) => s.x).toList();
      for (int i = 0; i < board.rows; i++) {
        if (board.rows == xPositions.where((x) => x == i).toList().length) {
          //det finns 9 olika squares i samma färg och ligger på samma kolumn. lodrätt bingo
          return true;
        }
      }
    }
    return false;
  }

  static List<Square> getBoardShadow(Piece piece, Square boardTile) {
    List<Square> shadow = piece.shape
        .map((s) =>
            new Square(s.x + boardTile.x, s.y + boardTile.y, true, piece.color)
              ..hasButton = s.hasButton)
        .toList();
    return shadow;
  }

  static List<Square> cropPiece(List<Square> shape) {
    int minY = shape.reduce((a, b) => a.y < b.y ? a : b).y;
    int minX = shape.reduce((a, b) => a.x < b.x ? a : b).x;

    List<Square> croppedShape = [];
    croppedShape.addAll(shape);

    while (minY > 0) {
      croppedShape.forEach((s) => s.y -= 1);
      minY = croppedShape.reduce((a, b) => a.y < b.y ? a : b).y;
    }
    while (minY < 0) {
      croppedShape.forEach((s) => s.y += 1);
      minY = croppedShape.reduce((a, b) => a.y < b.y ? a : b).y;
    }
    while (minX < 0) {
      croppedShape.forEach((s) => s.x += 1);
      minX = croppedShape.reduce((a, b) => a.x < b.x ? a : b).x;
    }
    while (minX > 0) {
      croppedShape.forEach((s) => s.x -= 1);
      minX = croppedShape.reduce((a, b) => a.x < b.x ? a : b).x;
    }
    return croppedShape;
  }

  static Piece rotatePiece(Piece piece) {
    List<Square> shape = piece.shape;
    List<Square> newShape = [];
    int maxX = shape.reduce((a, b) => a.x > b.x ? a : b).x;
    int centerX = (maxX / 2).round();
    int maxY = shape.reduce((a, b) => a.y > b.y ? a : b).y;
    int centerY = (maxY / 2).round();
    Square centerPoint = new Square.simple(centerX, centerY);

    List<int> rotationDirectionX = [0, -1];
    List<int> rotationDirectionY = [1, 0];

    for (int i = 0; i < shape.length; i++) {
      Square before = shape[i];
      Square vr =
          new Square.simple(before.x - centerPoint.x, before.y - centerPoint.y);
      int relativeNewPositionX =
          (rotationDirectionX[0] * vr.x) + (rotationDirectionX[1] * vr.y);
      int relativeNewPositionY =
          (rotationDirectionY[0] * vr.x) + (rotationDirectionY[1] * vr.y);
      Square relativeNewSquare =
          new Square.simple(relativeNewPositionX, relativeNewPositionY);

      before.x = centerPoint.x + relativeNewSquare.x;
      before.y = centerPoint.y + relativeNewSquare.y;
      newShape.add(before);
    }
    piece.shape = cropPiece(shape);
    return piece;
    //positionera om squares
  }

  static Piece flipPiece(Piece piece) {
    List<Square> shape = piece.shape;
    List<Square> newShape = [];
    int maxX = shape.reduce((a, b) => a.x > b.x ? a : b).x;
    int centerX = (maxX / 2).round();
    int maxY = shape.reduce((a, b) => a.y > b.y ? a : b).y;
    int centerY = (maxY / 2).round();
    Square centerPoint = new Square.simple(centerX, centerY);

    List<int> rotationDirectionX = [0, -1];
    List<int> rotationDirectionY = [1, 0];

    for (int i = 0; i < shape.length; i++) {
      Square before = shape[i];
      Square vr =
          new Square.simple(before.x - centerPoint.x, before.y - centerPoint.y);
      int relativeNewPositionX =
          (rotationDirectionX[0] * vr.x) + (rotationDirectionX[1] * vr.x);
      int relativeNewPositionY =
          (rotationDirectionY[0] * vr.y) + (rotationDirectionY[1] * vr.y);
      Square relativeNewSquare =
          new Square.simple(relativeNewPositionX, relativeNewPositionY);

      before.x = centerPoint.x + relativeNewSquare.x;
      before.y = centerPoint.y + relativeNewSquare.y;
      newShape.add(before);
    }
    piece.shape = cropPiece(shape);
    return piece;
    //positionera om squares
  }
}

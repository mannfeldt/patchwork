import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/lootBox.dart';
import 'package:patchwork/models/lootPrice.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/utilities/patchwork_icons_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static LootBox getLootBox(int value) {
    List<LootPrice> prices = [];
    Random rng = new Random();
    final List<LootType> types = LootType.values;
    for (int i = 0; i < lootBoxPricesNr; i++) {
      LootType type = types[rng.nextInt(types.length)];
      int amount;
      String data;
      Color priceColor;
      IconData icon;
      switch (type) {
        case LootType.CASH:
          icon = PatchworkIcons.button_icon;
          int nr = rng.nextInt(100);
          if (nr < 20) {
            amount = 2;
            priceColor = lootCommonColor;
          } else if (nr < 20 + 20) {
            amount = 3;
            priceColor = lootCommonColor;
          } else if (nr < 40 + 20) {
            amount = 4;
            priceColor = lootCommonColor;
          } else if (nr < 60 + 10) {
            amount = 5;
            priceColor = lootRareColor;
          } else if (nr < 70 + 10) {
            amount = 6;
            priceColor = lootRareColor;
          } else if (nr < 80 + 6) {
            amount = 7;
            priceColor = lootEpicColor;
          } else if (nr < 86 + 6) {
            amount = 8;
            priceColor = lootEpicColor;
          } else if (nr < 92 + 4) {
            amount = 9;
            priceColor = lootLegendaryColor;
          } else {
            amount = 10;
            priceColor = lootLegendaryColor;
          }
          break;
        case LootType.TIME:
          icon = Icons.access_time;
          int nr = rng.nextInt(100);
          if (nr < 30) {
            amount = 1;
            priceColor = lootCommonColor;
          } else if (nr < 30 + 30) {
            amount = 2;
            priceColor = lootCommonColor;
          } else if (nr < 60 + 20) {
            amount = 3;
            priceColor = lootRareColor;
          } else if (nr < 80 + 12) {
            amount = 4;
            priceColor = lootEpicColor;
          } else {
            amount = 5;
            priceColor = lootLegendaryColor;
          }
          break;
        default:
          break;
      }
      LootPrice lootPrice =
          new LootPrice(type, amount, data, i, priceColor, icon);
      prices.add(lootPrice);
    }
    LootPrice win = prices[rng.nextInt(prices.length)];
    prices.removeWhere((x) => x.id == win.id);

    int offsetIndex = rng.nextInt(5) + 5;
    int newIndex = lootBoxPricesNr - offsetIndex;
    prices.insert(newIndex, win);
    LootBox lootBox = new LootBox(win.id, prices, win, value);
    return lootBox;
  }

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

  static int emptyBoardSpaces(Board board) {
    int emptySpaces = (board.cols * board.rows) - board.squares.length;
    return emptySpaces;
  }

  static bool validateScissorsPlacement(Square placement, Board board) {
    bool valid = !hasRoom([placement], board);
    return valid;
  }

  static bool isFilled(List<Square> placement, Board board) {
    for (int i = 0; i < placement.length; i++) {
      Square square = placement[i];
      bool isUsed = board.squares.any((s) => s.samePositionAs(square));
      if (!isUsed) return false;
    }
    return true;
  }

  static void savePreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    print('saved $value');
  }

  static Future<String> getPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key) ?? null;
    return value;
  }

  static bool hasPattern(List<Square> pattern, Board board) {
    //kollat om ett mönster finns på en board. t.ex. 7x7 biten
    //börjar kolla om mönstret finns på ordinaeria plats och sedan flyttar pattern ett steg till höger tills det slår kanten
    //då flyttar mönsretet ner en rad och börjar kolla om det finns någon match på den raden fram tills att hela boardet har kollats
    //OBS kollar inte roterade mönster
    int maxY = pattern.reduce((a, b) => a.y > b.y ? a : b).y;
    int maxX = pattern.reduce((a, b) => a.x > b.x ? a : b).x;

    int diffY = board.rows - maxY;
    int diffX = board.cols - maxX;

    for (int x = 0; x < diffX; x++) {
      for (int y = 0; y < diffY; y++) {
        if (isFilled(pattern, board)) {
          return true;
        }
        pattern.forEach((s) {
          s.y += 1;
        });
      }
      pattern.forEach((s) {
        s.x += 1;
      });
      pattern.forEach((s) {
        s.y -= diffY;
      });
    }
    return false;
  }

  static bool isBoardComplete(Board board) {
    bool complete = board.squares.length == board.cols * board.rows;
    return complete;
  }

  static List<int> getBingoRows(Board board) {
    List<int> bingos = [];
    for (String imageSrc in pieceImages) {
      List<Square> matchingSquares =
          board.squares.where((s) => s.imgSrc == imageSrc).toList();
      List<int> yPositions = matchingSquares.map((s) => s.y).toList();
      for (int i = 0; i < board.rows; i++) {
        if (board.cols == yPositions.where((x) => x == i).toList().length) {
          //det finns 9 olika squares i samma färg och ligger på samma rad. vågrätt bingo
          bingos.add(i);
        }
      }
    }
    return bingos;
  }

  static List<Square> getBoardShadow(Piece piece, Square boardTile) {
    List<Square> shadow = piece.shape
        .map((s) =>
            new Square(s.x + boardTile.x, s.y + boardTile.y, true, s.imgSrc)
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
  }

  static bool isWithinTimeframe(Timestamp time, Timeframe timeframe) {
    switch (timeframe) {
      case Timeframe.WEEK:
        return isThisWeek(time);
        break;
      case Timeframe.MONTH:
        return isThisMonth(time);
        break;
      case Timeframe.ALL_TIME:
        return true;
        break;
      default:
        return false;
    }
  }

  static bool isThisWeek(Timestamp timestamp) {
    var now = new DateTime.now();
    var date = new DateTime.fromMicrosecondsSinceEpoch(
        timestamp.microsecondsSinceEpoch);
    var diff = now.difference(date);
    int daysAgo = diff.inDays;

//detnna är felvänt
    return daysAgo < 7 && date.weekday <= now.weekday;
  }

  static bool isThisMonth(Timestamp timestamp) {
    var now = new DateTime.now();
    var date = new DateTime.fromMicrosecondsSinceEpoch(
        timestamp.microsecondsSinceEpoch);
    return date.year == now.year && date.month == now.month;
  }
}

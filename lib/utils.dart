import 'dart:math';
import 'package:flutter/material.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/player.dart';

class Utils {
  static Square _west = new Square(-1, 0);
  static Square _east = new Square(1, 0);
  static Square _north = new Square(0, -1);
  static Square _south = new Square(0, 1);
  static final List directions = [_west, _east, _north, _south];
  static final List<Color> pieceColors = [
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.teal,
    Colors.pink
  ];
  static final Map<String, double> costAdjustments = {
    "SALE30": -0.3,
    "SALE20": -0.2,
    "SALE10": -0.1,
    "OVER10": 0.1,
    "OVER20": 0.2,
    "OVER30": 0.3,
    "NONE": 0.0
  };
}

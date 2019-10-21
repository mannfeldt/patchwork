import 'dart:io';

import 'package:flutter/material.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/score.dart';

class Player {
  int id;
  String name;
  int buttons;
  int position;
  Color color;
  bool isAi;
  String state; //wating, playing, finished
  Board board;
  bool hasSevenBySeven;
  Score score;
  List<int> bingos;
  bool screenShotted;
  File screenshot;

  Player(int id, String name, Color color, bool isAi) {
    this.id = id;
    this.name = name;
    this.color = color;
    this.isAi = isAi;
    this.state = "waiting";
    this.position = 0;
    this.buttons = 300;//återsältt till 5
    this.hasSevenBySeven = false;
    this.board = new Board(this);
    this.bingos = [];
    this.screenShotted = false;
  }
}

import 'package:flutter/material.dart';
import 'package:patchwork/models/board.dart';

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
  int score;

  Player(int id, String name, Color color, bool isAi) {
    this.id = id;
    this.name = name;
    this.color = color;
    this.isAi = isAi;
    this.state = "waiting";
    this.position = 0;
    this.buttons = 5;
    this.hasSevenBySeven = false;
    this.score = 0;
    this.board = new Board(this);
  }
}

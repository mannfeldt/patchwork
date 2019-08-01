import 'package:patchwork/models/board.dart';
class Player {
  int id;
  String name;
  int buttons;
  int position;
  bool isAI;
  String state; //wating, playing, finished
  Board board;

  Player();
}

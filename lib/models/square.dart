import 'package:flutter/material.dart';

class Square {
  int id;
  int x;
  int y;
  bool hasButton;
  String
      state; //dead, cloth, wool, cotton, silk. kan användas till vad som. om man dödar någons bräde eller om man startar med ett bräde med hål i så kan en square läggas där
  Color color;
  bool filled;

  Square(int x, int y, bool filled) {
    this.x = x;
    this.y = y;
    this.hasButton = false;
    this.filled = filled;
  }
}

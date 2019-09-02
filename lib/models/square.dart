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
  String imgSrc;
  bool topStitching = false;
  bool leftStitching = false;

  Square(int x, int y, bool filled, String imgSrc) {
    this.x = x;
    this.y = y;
    this.hasButton = false;
    this.color = color;
    this.filled = filled;
    this.imgSrc = imgSrc;
  }
  Square.simple(int x, int y) {
    this.x = x;
    this.y = y;
    this.hasButton = false;
    this.filled = false;
  }

  bool samePositionAs(Square square) {
    return square.x == this.x && square.y == this.y;
  }
}

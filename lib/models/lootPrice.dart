import 'package:flutter/material.dart';

enum LootType { CASH, TIME }

class LootPrice {
  LootType type;
  int amount;
  String data;
  int id;
  Color color;
  IconData icon;

  LootPrice(LootType type, int amount, String data, int id, Color color, IconData icon) {
    this.type = type;
    this.amount = amount;
    this.data = data;
    this.id = id;
    this.color = color;
    this.icon = icon;
  }
}

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Highscore {
  String name;
  String userId;
  int score;
  int scoreMinus;
  int scoreExtra;
  String mode;
  Timestamp time;

  Highscore.fromJson(var data) {
    this.name = data['name'];
    this.userId = data['userId'];
    this.score = data['score'];
    this.scoreMinus = data['scoreMinus'];
    this.scoreExtra = data['scoreExtra'];
    this.mode = data['mode'];
    this.time = data['time'];
  }
  Highscore();

  String getJson() {
    return jsonEncode(this);
  }
}

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patchwork/models/player.dart';

class Highscore implements Comparable {
  String name;
  String userId;
  int score;
  int scoreMinus;
  int scoreExtra;
  String mode;
  Timestamp time;
  bool isNew;
  int id;
  String screenshot;
  String thumbnail;
  String emoji;
  String key;

  Highscore.fromJson(var data) {
    this.name = data['name'];
    this.userId = data['userId'];
    this.score = data['score'];
    this.scoreMinus = data['scoreMinus'];
    this.scoreExtra = data['scoreExtra'];
    this.mode = data['mode'];
    this.time = data['time'];
    this.id = data['id'];
    this.screenshot = data['screenshot'];
    this.thumbnail = this.screenshot.replaceFirst(".png",
        "_180x180.png"); //det funkar inte. det är massa tecken efter png i urlen som är unikt för thubnailen..

    this.emoji = data['emoji'];
    // this.key = data['key'];
    this.isNew = false;
  }
  Highscore(Player player, int id) {
    this.name = player.name;
    this.userId = player.id.toString();
    this.score = player.score.plus;
    this.scoreMinus = player.score.minus;
    this.scoreExtra = player.score.extra;
    this.emoji = player.emoji;
    this.mode = null;
    this.time = Timestamp.now();
    this.id = id;
    this.isNew = true;
  }

  String get displayname {
    return this.emoji + " " + this.name;
  }

  String getJson() {
    return jsonEncode(this);
  }

  int getTotal() {
    return this.score - this.scoreMinus + this.scoreExtra;
  }

  bool isSameAs(Highscore other) {
    return other.id == this.id;
  }

  @override
  int compareTo(other) {
    int result = other.getTotal() - this.getTotal();
    if (result != 0) return result;

    return other.time.compareTo(this.time);
  }
}

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

  Highscore.fromJson(var data) {
    this.name = data['name'];
    this.userId = data['userId'];
    this.score = data['score'];
    this.scoreMinus = data['scoreMinus'];
    this.scoreExtra = data['scoreExtra'];
    this.mode = data['mode'];
    this.time = data['time'];
    this.id = data['id'];
    this.isNew = false;
  }
  Highscore(Player player, int id) {
    this.name = player.name;
    this.userId = player.id.toString();
    this.score = player.score.plus;
    //behöver få in mer info till denna konstruktor eller ha mer info på playerbojektet.
    //behöver. score, minusScore, Extrascore, gamemode,

    //just nu räknar jag ut dessa i endScreen widgeten. Detta borde ske direkt när man går imål och sparas på player.
    //där borde kanske uträkning av om det var ett highscore eller inte också göras?
    //gamemode vill jag inte para på playerobjektet. det kan jag skicka in här som separat parameter
    //det finns ju metoder i gameengine som räknas ut score. den borde returnera ett score objekt som då är score, minusScore, ExtraScore som läggs till på playerobjektet.

    this.scoreMinus = player.score.minus;
    this.scoreExtra = player.score.extra;
    this.mode = null;
    this.time = Timestamp.now();
    this.id = id;
    this.isNew = true;
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

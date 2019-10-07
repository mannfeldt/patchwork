import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patchwork/models/highscore.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/utilities/utils.dart';

//skicka in ett api objekt till denna provider? som PE gör. sen är det den API filen som sköter alla anrop till firebase

class HighscoreState with ChangeNotifier {
  List<Highscore> _highscores;
  int _nextPlayerToCheckHighscore = 0;
  bool _isShowingNewHighscore = false;

  final databaseReference = Firestore.instance;

  getAllHightscores() => _highscores;
  getNextPlayerToCheckHIghscore() => _nextPlayerToCheckHighscore;
  isShowingNewHighscore() => _isShowingNewHighscore;

  List<Highscore> getHighscores(Timeframe timeframe, GameMode gameMode) {
    List<Highscore> filteredHighscore = [];
    filteredHighscore = _highscores
        .where((h) =>
            h.mode == gameModeName[gameMode] &&
            Utils.isWithinTimeframe(h.time, timeframe))
        .toList();
    filteredHighscore.sort((a, b) => a.compareTo(b));
    filteredHighscore.length = min(filteredHighscore.length, highscoreLimit);

    return filteredHighscore;
  }

  void saveHighscore(Highscore highscore) async {
    await databaseReference.collection("highscores").add({
      'userId': highscore.userId,
      'name': highscore.name,
      'score': highscore.score,
      'scoreMinus': highscore.scoreMinus,
      'scoreExtra': highscore.scoreExtra,
      'time': highscore.time,
      'mode': highscore.mode
    }).then(
        (
          onValue,
        ) =>
            {print("hello")},
        onError: (e) => {print(e.toString())});
    highscore.isNew = false; //?
    _highscores.add(highscore);
    // _nextPlayerToCheckHighscore += 1;
    _isShowingNewHighscore = false;
    print("SAVE HIGHSCORE");
    notifyListeners();
  }

  void setShowingNewHighscore(bool showingNewHighscore) {
    _isShowingNewHighscore = showingNewHighscore;
    notifyListeners();
  }

  int getAllTimeRanking(GameMode gameMode, int score) {
    List<Highscore> betterHighscores = _highscores
        .where((h) => h.mode == gameModeName[gameMode] && h.getTotal() > score)
        .toList();
    //använder jag denna ranking blir det ju lite missvisande då jag inte sparar allas poäng
    //ska jag kanske göra det?
    //jag borde sätta upp en testmiljö för firebase så jag kan testa mot highscore utan att påverka för användare/riktiga hs.
    //skapa ett byggscript på samma sätt som PE, med frontline(?) som ändrar ENV till prod vid bygge och automatiskt updaterar play store.
    //detta vill jag ha på plats innan release
    return betterHighscores.length;
  }

  void newGame() {
    _nextPlayerToCheckHighscore = 0;
    notifyListeners();
  }

//refactorer så det är likt PE. vill använda future builder så vill returnera en någon future?
  // void fetchHighscores() {
  //   databaseReference
  //       .collection("highscores")
  //       .getDocuments()
  //       .then((QuerySnapshot snapshot) {
  //     //läs och tranformera till hightscore modelen jag inte har än. och lägg till dem i listan _highscores
  //     snapshot.documents.forEach((f) => print('${f.data}}'));

  //     snapshot.documents.forEach((f) => {_highscores.add(f.data['name'])});
  //   });
  // }

  bool checkHighscore(Timeframe timeframe, GameMode gameMode, int score) {
    List<Highscore> filteredHighscores = getHighscores(timeframe, gameMode);
    if (filteredHighscores.length < highscoreLimit) {
      return true;
    }
    int scoreToBeat =
        filteredHighscores[filteredHighscores.length - 1].getTotal();
    if (score > scoreToBeat) {
      return true;
    }
    return false;
  }

  Timeframe getNewHighscoreTimeframe(Player player, GameMode gameMode) {
    if (checkHighscore(Timeframe.ALL_TIME, gameMode, player.score.total)) {
      return Timeframe.ALL_TIME;
    }
    if (checkHighscore(Timeframe.MONTH, gameMode, player.score.total)) {
      return Timeframe.MONTH;
    }
    if (checkHighscore(Timeframe.WEEK, gameMode, player.score.total)) {
      return Timeframe.WEEK;
    }
    return null;
  }

  Future<List<Highscore>> fetchHighscores() async {
    if (_highscores == null) {
      await databaseReference
          .collection("highscores")
          .getDocuments()
          .then((QuerySnapshot snapshot) {
        //läs och tranformera till hightscore modelen jag inte har än. och lägg till dem i listan _highscores
        snapshot.documents.forEach((f) => print('${f.data}}'));
        _highscores = [];
        snapshot.documents
            .forEach((f) => {_highscores.add(Highscore.fromJson(f.data))});
        // return _highscores;
      });
    }
    notifyListeners();
    return _highscores;
  }
}

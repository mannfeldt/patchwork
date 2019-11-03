import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patchwork/models/highscore.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/utilities/utils.dart';

class HighscoreState with ChangeNotifier {
  List<Highscore> _highscores;
  int _nextPlayerToCheckHighscore = 0;
  bool _isShowingNewHighscore = false;

  final databaseReference = Firestore.instance;
  final StorageReference storageReference = FirebaseStorage().ref();
  final FirebaseAuth auth = FirebaseAuth.instance;

  getAllHightscores() => _highscores;
  getNextPlayerToCheckHIghscore() => _nextPlayerToCheckHighscore;
  isShowingNewHighscore() => _isShowingNewHighscore;

  List<Highscore> getHighscores(Timeframe timeframe, GameMode gameMode) {
    if (_highscores == null) return [];
    List<Highscore> filteredHighscore = [];
    filteredHighscore = _highscores
        .where((h) =>
            h.mode == gameMode.toString() &&
            Utils.isWithinTimeframe(h.time, timeframe))
        .toList();
    filteredHighscore.sort((a, b) => a.compareTo(b));
    filteredHighscore.length = min(filteredHighscore.length, highscoreLimit);

    return filteredHighscore;
  }

  void saveHighscore(Highscore highscore, Player player) async {
    await auth.signInAnonymously();
    String extension = "png";
    final String fileName = 'screen_' +
        DateTime.now().millisecondsSinceEpoch.toString() +
        '.$extension';

    final StorageReference imageRef =
        storageReference.child('highscore_screenshots').child(fileName);
    final StorageUploadTask uploadTask = imageRef.putFile(
      player.screenshot,
    );

    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());

    highscore.screenshot = url;

//det är möjligt att köra en tom add({}) och köra ref.documentId på det jag fårsom svar och sen köra ref.set eller liknande
    await databaseReference.collection("highscores").add({
      'userId': highscore.userId,
      'name': highscore.name,
      'score': highscore.score,
      'scoreMinus': highscore.scoreMinus,
      'scoreExtra': highscore.scoreExtra,
      'time': highscore.time,
      'mode': highscore.mode,
      'screenshot': highscore.screenshot,
      'emoji': highscore.emoji,
    }).then(
        (
          onValue,
        ) =>
            {print("SAVE HIGHSCORE")},
        onError: (e) => {print(e.toString())});
    highscore.isNew = false; //?
    _highscores.add(highscore);
    _isShowingNewHighscore = false;
    //notifyListeners();
  }

  void setShowingNewHighscore(bool showingNewHighscore) {
    _isShowingNewHighscore = showingNewHighscore;
    // notifyListeners();
  }

  String getBackgroundImage(GameMode mode) {
    List<Highscore> highscores = getHighscores(Timeframe.ALL_TIME, mode);
    if (highscores.isEmpty) return "";
    return highscores[0].screenshot;
  }

  int getAllTimeRanking(GameMode gameMode, int score) {
    List<Highscore> betterHighscores = _highscores
        .where((h) => h.mode == gameMode.toString() && h.getTotal() > score)
        .toList();
    return betterHighscores.length;
  }

  void newGame() {
    _nextPlayerToCheckHighscore = 0;
    notifyListeners();
  }

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

  // Map<Timeframe, int> getHighscoreRankings(Highscore highscore) {
  //   Map<Timeframe, int> rankings = Map<Timeframe, int>();
  //   GameMode mode =
  //       GameMode.values.firstWhere((g) => g.toString() == highscore.mode);
  //   for (Timeframe timeframe in Timeframe.values) {
  //     int ranking = getHighscores(timeframe, mode)
  //         .where((h) => h.getTotal() > highscore.getTotal())
  //         .toList()
  //         .length;
  //     rankings.putIfAbsent(timeframe, () => ranking);
  //   }

  //   return rankings;
  // }

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
        _highscores = [];
        snapshot.documents
            .forEach((f) => {_highscores.add(Highscore.fromJson(f.data))});
      });
    }
    notifyListeners();
    return _highscores;
  }
}

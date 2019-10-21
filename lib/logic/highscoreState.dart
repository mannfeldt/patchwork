import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart';
import 'package:image/image.dart' as prefix1;
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
  final StorageReference storageReference = FirebaseStorage().ref();
  final FirebaseAuth auth = FirebaseAuth.instance;

  getAllHightscores() => _highscores;
  getNextPlayerToCheckHIghscore() => _nextPlayerToCheckHighscore;
  isShowingNewHighscore() => _isShowingNewHighscore;

  List<Highscore> getHighscores(Timeframe timeframe, GameMode gameMode) {
    if(_highscores == null) return [];
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

  void saveHighscore(Highscore highscore, Player player) async {
    //det tar lite tid nu att spara? kolla hur lång tid. ersätt knappen med en spinner under tiden eller något. gör det lokalt i state i newhighscoretable isf.
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

    highscore.thumbnail = url;
    highscore.screenshot = url;

    // final String thumbFileName = 'thumb' +
    //     DateTime.now().millisecondsSinceEpoch.toString() +
    //     '.$extension';

    // prefix1.Image image = decodeImage(player.screenshot.readAsBytesSync());

    // prefix1.Image thumbnail = copyResize(image, width: 120, height: 120);

    // final StorageReference thumbRef =
    //     storageReference.child('highscore_screenshots').child(thumbFileName);
    // final StorageUploadTask uploadTaskThumb = thumbRef.putData(
    //   thumbnail.getBytes(),
    // );

    // final StorageTaskSnapshot downloadUrlThumb =
    //     (await uploadTaskThumb.onComplete);
    // final String thumbUrl = (await downloadUrlThumb.ref.getDownloadURL());

    //TODO
    // jag ser att jag får fortarande vitt prices på gameboard ibland...
    // googla lite på hur jag kan ändra tankesätt för detta med async vid rerender är ju inte hållbart som jag gör nu med amassa flagor
    // vad är det för mönster jag saknar? något missar jag nog.

    //testa igenom allt. olika många spelare. bingo classic. animation vid finish och inte. pass och putpice. scissor extra pice

    await databaseReference.collection("highscores").add({
      'userId': highscore.userId,
      'name': highscore.name,
      'score': highscore.score,
      'scoreMinus': highscore.scoreMinus,
      'scoreExtra': highscore.scoreExtra,
      'time': highscore.time,
      'mode': highscore.mode,
      'screenshot': highscore.screenshot,
      'thumbnail': highscore.thumbnail,
    }).then(
        (
          onValue,
        ) =>
            {print("SAVE HIGHSCORE")},
        onError: (e) => {print(e.toString())});
    highscore.isNew = false; //?
    _highscores.add(highscore);
    // _nextPlayerToCheckHighscore += 1;
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
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patchwork/models/highscore.dart';

//skicka in ett api objekt till denna provider? som PE gör. sen är det den API filen som sköter alla anrop till firebase

class SessionState with ChangeNotifier {
  List<Highscore> _highscores = null;

  final databaseReference = Firestore.instance;

  getHightscores() => _highscores;

  void saveHightscore() async {
    await databaseReference.collection("highscores").add({
      'name': 'ASD',
      'score': 40,
      'minusScore': 10,
      'time': new DateTime.now(),
      'userId': 2,
      'mode': 'STANDARD'
    });
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

  Future<List<Highscore>> fetchHighscores() async {
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
    notifyListeners();
    return _highscores;
  }
}

import 'dart:async';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/timeBoard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState with ChangeNotifier {
  String _gameId;
  String _playerKey;
  
  String gameMode;
  int currentPlayer;
  List<Player> players; // player holds boardsstate(nytt objekt som inkluderar en lista med pieces, boardbuttons), buttonCash, position (timeboard), isAi, 
  TimeBoard timeBoard; //holds position of extra squares and buttons and goal. Has one default which is the replica but can also be randomly generated.
  List<Piece> gamePieces;
  GameState(this._gameId);

  void setGameId(String gameId) {
    _gameId = gameId;
    notifyListeners();
  }

  getGameId() => _gameId;

  void putPiece(Piece piece, int x, int y ){
    //det är the left top most square of the piece som räknas som där den sätts ned.
    //den squaren kallas firstTouchSquare eller något. Den lägs på coordinaterna x och y och sen faller resteraden squares på plats utefter deras relativa position
    //x och y för varje square på piecen skrivs om enligt den förflyttningen. Alltså leftTopMostSquare blir på position x,y som är inparametrarna.
    //kolla då hur den den biten påverkas hur mycket ökar/mindskar x och y från vad den var från början? addera samma förändringsvärde på alla squares på piecen
    //viktigt att roteringar av biten räknas med. Kommer väl ha en metod i piece för att rotera / spegla biten. Då skrivs ju alla koordinater om och vi får en ny square som blir leftTopMostSquare
    //behöver också ha en valideringsgrej som kollar ifall det är ett giltigt ställe att lägga biten. kanske ska vara aktivt så när man drar den över rutor så ska rutorna under blir gröna om det passar. 
  }


  void _saveToPrefs(String key, String value) async {
    //https://pusher.com/tutorials/local-data-flutter
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    print('saved $value');
  }

  void _readFromPrefs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key) ?? null;
    _playerKey = value;

    //det är async så kan inte bara returnera rakt av. antingen sättar jag state här när det är klart
  }

}

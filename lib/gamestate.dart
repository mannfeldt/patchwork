import 'dart:async';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/timeBoard.dart';
import 'package:flutter/material.dart';
import 'package:patchwork/ruleEngine.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState with ChangeNotifier {
  String _gameId;
  String _playerKey;

  String gameMode;
  int currentPlayer;
  int pieceMarkerIndex;
  Piece currentPiece; //biten som användaren valt att placera
  List<Player> players; // player holds boardsstate(nytt objekt som inkluderar en lista med pieces, boardbuttons), buttonCash, position (timeboard), isAi, 
  TimeBoard timeBoard; //holds position of extra squares and buttons and goal. Has one default which is the replica but can also be randomly generated.
  List<Piece> gamePieces;
  GameState(this._gameId);

  void setGameId(String gameId) {
    _gameId = gameId;
    notifyListeners();
  }

  getGameId() => _gameId;
//behöver identifiera alla acions man gör i spelet och placera dem i gamestate här och eventuellt skapa utrymme för dem i models
  void putPiece(Piece piece, int x, int y ){
    //currentplayer.board.addpiece()
    //det är the left top most square of the piece som räknas som där den sätts ned.
    //den squaren kallas firstTouchSquare eller något. Den lägs på coordinaterna x och y och sen faller resteraden squares på plats utefter deras relativa position
    //x och y för varje square på piecen skrivs om enligt den förflyttningen. Alltså leftTopMostSquare blir på position x,y som är inparametrarna.
    //kolla då hur den den biten påverkas hur mycket ökar/mindskar x och y från vad den var från början? addera samma förändringsvärde på alla squares på piecen
    //viktigt att roteringar av biten räknas med. Kommer väl ha en metod i piece för att rotera / spegla biten. Då skrivs ju alla koordinater om och vi får en ny square som blir leftTopMostSquare
    //behöver också ha en valideringsgrej som kollar ifall det är ett giltigt ställe att lägga biten. kanske ska vara aktivt så när man drar den över rutor så ska rutorna under blir gröna om det passar. 
    
    //denna metod ska räkna ut nya koordinater för piece.squares() men sen kör vi board.addPiece(piece) som bara lägger till den i listan
    //kanske använda ruleEngine också? refacotirsera senare


    //ska också ta betalt för biten i buttons currentplayer.buttons -= cost
    //om putpiece fungerar så är nästa steg att köra movePlayerPosition()
    // och sen köra ruleEngine.getNextPlayer(board) som retunrerar spelarens tur, sätter currentplayer

    //0. vi har tidigare validerat att det är en valid plats att lägga biten på för att komma hit. vi använder då ruleengine.validatePlacement
    //1. räkna ut piece.squares koordinater med hjälp av x,y som blir den leftTopMostSquare.
    //2. lägg till biten l listan på player.board.pieces
    //3. ta bort piecen från this.gamePieces
    //4. Flytta fram pieceMarkerIndex till piecens tidigare plats
    //5. ta betalt för piecen. player.buttons -= piece.cost (detta skulle kunna göras tillsammans med steg 6 i metoden som anropas i steg 2 om det istället är player.addPiece())
    //6. flytta player.position och kolla efter events. movePlayerPosition(piece.time)
    //7. nextTurn()

    
  }
  
  void selectPiece(Piece piece){
  
  }

  void nextTurn(){
    currentPlayer = RuleEngine.getNextPlayerIndex(players, currentPlayer);
    Player player = players[currentPlayer];
    //det här neda hör ju också till reglerna?
    for(int i = pieceMarkerIndex; i< pieceMarkerIndex+3; i++){
        Piece p = gamePieces[i];
        if(RuleEngine.canSelectPiece(p, player)){
          p.state = "selectable";
        }else{
          p.state = "unselectable";
        }
    }
  }

  void movePlayerPosition(int moves){
    //takes currentplayer och flyttar framåt positionen..
    //kolla ifall man passerar något event på timeboarden (extra priece or buttonspoint or goalline)

  }
  void pass(){
    //räkna ut hur många moves en pass blir och dela ut buttons för det
    //sen kör movePlayerPosition(moves); // som är den vanliga moven som kollar events etc.
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

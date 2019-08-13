import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/models/timeBoard.dart';
import 'package:flutter/material.dart';
import 'package:patchwork/defaultGameMechanics.dart';
import 'package:patchwork/patchworkRuleEngine.dart';
import 'package:patchwork/survivalGameMechanics.dart';
import 'package:patchwork/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'package:patchwork/constants.dart';

class GameState with ChangeNotifier {
  PatchworkRuleEngine _ruleEngine;
  double _boardTileSize;
  ui.Image _image;
  Player _currentPlayer;
  Board _currentBoard;
  Piece _draggedPiece;
  bool _extraPieceCollected;
  int _pieceMarkerIndex;
  Square _hoveredBoardTile;
  List<Square> _boardHoverShadow;
  List<Player> _players = [];
  TimeBoard _timeBoard;
  List<Piece> _gamePieces;
  String _view;

  GameState();

  getView() => _view;
  getTimeBoard() => _timeBoard;
  getCurrentPlayer() => _currentPlayer;
  getGamePieces() => _gamePieces;
  getPlayers() => _players;
  getImg() => _image;
  getBoardTileSize() => _boardTileSize;
  getExtraPieceCollected() => _extraPieceCollected;
  getDraggedPiece() => _draggedPiece;
  getHoveredBoardTile() => _hoveredBoardTile;
  getBoardHoverShadow() => _boardHoverShadow;
  getCurrentBoard() => _currentBoard;

  void setView(String view) {
    _view = view;
    notifyListeners();
  }

  List<Square> setHoveredBoardTile(Square boardTile) {
    List<Square> shadow = Utils.getBoardShadow(_draggedPiece, boardTile);
    _boardHoverShadow = shadow;

    _hoveredBoardTile = boardTile;
    notifyListeners();
    return _boardHoverShadow;
  }

  void cleaHoverBoardTile() {
    _hoveredBoardTile = null;
    _boardHoverShadow = null;
    notifyListeners();
  }

  void setDraggedPiece(Piece p) {
    _draggedPiece = p;
    notifyListeners();
  }

  void dropDraggedPiece() {
    _draggedPiece = null;
    notifyListeners();
  }

  void addPlayer(String name, Color color, bool isAi) {
    Player player = new Player(_players.length, name, color, isAi);
    _players.add(player);
    notifyListeners();
  }

  void removePlayer(Player player) {
    _players.removeWhere((p) => p.id == player.id);
    notifyListeners();
  }

  Future<Null> init() async {
    final ByteData data = await rootBundle.load('assets/J.png');
    _image = await loadImage(new Uint8List.view(data.buffer));
    notifyListeners();
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  void restartApp() {
    _view = null;
    _players.clear();
    notifyListeners();
  }

  void setBoardTileSize(Size screenSize) {
    //varje boardTile ska ha en padding
    double boardTileSpace =
        screenSize.width - 1 - (boardTilePadding * _currentBoard.cols);
    _boardTileSize = boardTileSpace / _currentBoard.cols;
    //notifyListeners(); får error för eveig loop?
  }

  void startGame(GameMode mode) {
    init();
    switch (mode) {
      case GameMode.DEFAULT:
        _ruleEngine = new DefaultGameMechanics();
        break;
      case GameMode.SURVIVAL:
        _ruleEngine = new SurvivalGameMechanics();
        break;
      default:
        break;
    }
    _view = "gameplay";
    _gamePieces = _ruleEngine.generatePieces(_players.length);
    _timeBoard = _ruleEngine.initTimeBoard();
    _players = _ruleEngine.initPlayers(_players);
    _pieceMarkerIndex = 0;
    _currentPlayer = _players[0];
    _currentBoard = _currentPlayer.board;
    _extraPieceCollected = false;
    nextTurn();
    notifyListeners();
  }

  void updateHoverBoard() {
    if (_hoveredBoardTile != null && _draggedPiece != null) {
      List<Square> shadow =
          Utils.getBoardShadow(_draggedPiece, _hoveredBoardTile);
      _boardHoverShadow = shadow;
    }
    notifyListeners();
  }

  void rotatePiece(Piece piece) {
    piece = Utils.rotatePiece(piece);
    updateHoverBoard();
    notifyListeners();
  }

  void flipPiece(Piece piece) {
    piece = Utils.flipPiece(piece);
    updateHoverBoard();
    notifyListeners();
  }

//behöver identifiera alla acions man gör i spelet och placera dem i gamestate här och eventuellt skapa utrymme för dem i models
  void putPiece(Piece piece, int x, int y) {
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

    for (int i = 0; i < piece.shape.length; i++) {
      Square square = piece.shape[i];
      square.x += x;
      square.y += y;
    }
    cleaHoverBoardTile();
    _currentBoard.addPiece(piece);
    _currentPlayer.buttons -= piece.cost;
    _pieceMarkerIndex = _gamePieces.indexWhere((p) => p.id == piece.id);
    _gamePieces.removeAt(_pieceMarkerIndex);
    movePlayerPosition(piece.time);

    //skipa nextTurn ifall att man får en extra tur med gratisbiten
  }

//fortsätt här
// 1. _ruleEngine.test(this); se detta i gamestate. fixa till det enligt kommentarer. skicka alltid med this och bara ha void metoder i ruleengine?
//nej det är bra att se vad som kommer tillbaka. skicka bara med this om det är något krångligt som kräver mer än en return. t.ex. pass? eller ska jag skicka med en callback i de fallen?
  // 2. fixa till gameboard så att den är centeread, just nu är det bara padding till höger. använd inset eller Center
  // 3. centrera button och pieces på timeboard. använd Stack och Center så att både knappar, pieces och players är centeraade och players ska då vara ovanpå knappar/pieces 
  // 4. märk ut tydligare vilka bitar som är draggable, med en skugga kanske 
  // 4.5 lägg till så att man ser om en bit är på rea, det gäller då främst bitar från survival. en flaga med procenten eller en överstruken siffra som är ordinreie pris. färgkoda för rea eller överpris? eller någon bra ikon?
  // 5. testa spela survival, modifiera peicesgeneratorn till att vara mer spelbar eller modifera timeboard för att bättre passa, t.ex starta med mer cash, flera cashpoints?
  // 6. gå igenom alla roliga mechanics jag har listat i google keep och skriv upp dem och placera in dem i passande gamemodes, tänk på inte för krångliga modes 
  // 7. se om jag fått svar på stack overflow, fråga annat forum? reddit flutter?


  void extraPiecePlaced(Piece piece, int x, int y) {
    for (int i = 0; i < piece.shape.length; i++) {
      Square square = piece.shape[i];
      square.x += x;
      square.y += y;
    }
    cleaHoverBoardTile();
    _extraPieceCollected = false;
    _currentBoard.addPiece(piece);

    nextTurn();
  }

  void _finishGame() {
    _view = "finished";
    _players
        .forEach((player) => player.score = _ruleEngine.calculateScore(player));
    notifyListeners();
  }

  void nextTurn() {
    bool gameFinished = _ruleEngine.isGameFinished(_players);
    if (gameFinished) {
      _finishGame();
    }
    _currentPlayer = _ruleEngine.getNextPlayer(_players, _currentPlayer);
    _currentBoard = _currentPlayer.board;
    //det här neda hör ju också till reglerna?
    List<Piece> cut = _gamePieces.sublist(0, _pieceMarkerIndex);
    List<Piece> newStart = _gamePieces.sublist(_pieceMarkerIndex);
    newStart.addAll(cut);
    _gamePieces = newStart;
    for (int i = 0; i < 3; i++) {
      Piece p = _gamePieces[i];
      p.selectable = _ruleEngine.canSelectPiece(p, _currentPlayer);
    }
    notifyListeners();
  }

  void movePlayerPosition(int moves) {
    int before = _currentPlayer.position;
    _currentPlayer.position += moves;
    int after = _currentPlayer.position;
    bool passedButton =
        _timeBoard.buttonIndexes.any((b) => b <= after && b > before);
    int passedPieceIndex = _timeBoard.pieceIndexes
        .firstWhere((b) => b <= after && b > before, orElse: () => -1);

    if (passedButton) {
      _currentPlayer.buttons += _currentBoard.buttons;
    }
    if (passedPieceIndex > 0) {
      _extraPieceCollected = true;
      _timeBoard.pieceIndexes.removeWhere((p) => p == passedPieceIndex);
    }

    //här får jag kolla igenom alla möjliga enums som kan vara med i _gamemechanics.timeBoardMechanics

    //innan nextturn så får jag kolla igenom alla enums i _gameMechanics.gameBoardMechanics

    //jag har då switches som är för varje befintlig enum som då köra något speiciellt

    //eller om jag kommer på färdiga gamemodes. och då har varje färdig gameMode en samling regler. och en gameModeMechanics klass håller koll på det
    //gamestate har då en gameModeMechanics klass som är en klass som ärver metoder från ruleEngine. så hela gamestate går inte direkt mot ruleEngine utan mot
    //_gameModeMechanics
    //så jag har en klass som är DefaultMechanics extens PatchworkRuleEngine.
    //i setup så väljer jag mode och varje modeklass är kopplat till en enum
    //gamestate.setGameModeMechanics(new DefaultMechanics)

    //jag måste flytta lite fler metoder till gameEngine och inte ha dem istate bara. allt som har med modes att göra? eller jag måste inte kanske

    if (after >= _timeBoard.goalIndex) {
      _currentPlayer.state = "finished";
      _currentPlayer.position = _timeBoard.goalIndex + 1;
    }
    if (!_extraPieceCollected) {
      nextTurn();
    } else {
      notifyListeners();
    }

    //om man inte fick en bit så är det nästa spelares tur

    //takes currentplayer och flyttar framåt positionen..
    //kolla ifall man passerar något event på timeboarden (extra priece or buttonspoint or goalline)
  }

  void pass() {
    int nextPlayersPosition = _players
        .where((p) => p.id != _currentPlayer.id)
        .reduce((a, b) => a.position < b.position ? a : b)
        .position;
    int moves = (nextPlayersPosition - _currentPlayer.position) + 1;
    _currentPlayer.buttons += moves;
    _pieceMarkerIndex = 0;



    //detta förändrar mycket jag kan då skicka in state och få ändra saker smidigt
    //typ är kan jag köra _ruleengine.pass(this) och inte behöva skicka med alla parametrar
    //och kan kan använda seters etc i ruleengine.
    //testa ersätt pass och movePosition/eller den del av moveposition som har med att kolla om man passerat något. 
    //lägg det i ruleegine
    //gamestate ska bara hålla korrekt data, bestå av getters och setters samt hanetra actions från avnändaren.
    //kan kan hantera putpiece eller scannboard i ruleengine som kan göra lite vad som egentligen
    _ruleEngine.test(this);

    movePlayerPosition(moves);
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
    // _playerKey = value;

    //det är async så kan inte bara returnera rakt av. antingen sättar jag state här när det är klart
  }
}

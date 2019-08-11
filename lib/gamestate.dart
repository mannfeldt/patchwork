import 'dart:async';
import 'dart:typed_data';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/models/timeBoard.dart';
import 'package:flutter/material.dart';
import 'package:patchwork/ruleEngine.dart';
import 'package:patchwork/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'package:patchwork/constants.dart';

class GameState with ChangeNotifier {
  double _boardTileSize;
  String _gameId;
  ui.Image _image;
  String gameMode;
  Player _currentPlayer;
  bool _extraPieceCollected;
  int _pieceMarkerIndex;
  Piece _currentPiece; //biten som användaren valt att placera
  List<Player> _players =
      []; // player holds boardsstate(nytt objekt som inkluderar en lista med pieces, boardbuttons), buttonCash, position (timeboard), isAi,
  TimeBoard
      _timeBoard; //holds position of extra squares and buttons and goal. Has one default which is the replica but can also be randomly generated.
  List<Piece> _gamePieces;
  String _view;

  GameState(this._gameId);

  void setView(String view) {
    _view = view;
    notifyListeners();
  }

  getView() => _view;
  getTimeBoard() => _timeBoard;
  getCurrentPiece() => _currentPiece;
  getCurrentPlayer() => _currentPlayer;
  getGamePieces() => _gamePieces;
  getPlayers() => _players;
  getImg() => _image;
  getBoardTileSize() => _boardTileSize;
  getExtraPieceCollected() => _extraPieceCollected;

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

  void setBoardTileSize(Size screenSize) {
    double boardTileSpace =
        screenSize.width - 1 - (boardTilePadding * _currentPlayer.board.cols);
    _boardTileSize = boardTileSpace / _currentPlayer.board.cols;
    //notifyListeners(); får error för eveig loop?
  }

  void startGame() {
    init();
    _view = "gameplay";
    List<Piece> ps =RuleEngine.generatePieces();
    _gamePieces = ps;
    _gamePieces.shuffle();
    _timeBoard = new TimeBoard("default");
    _pieceMarkerIndex = 0;
    _currentPlayer = _players[0];
    _extraPieceCollected = false;
    // ! TESTs
    //_currentPlayer.board.pieces.add(_gamePieces[2]);

    nextTurn();
    notifyListeners();
  }

  void updateHoverBoard(List<Square> hovered) {
    _currentPlayer.board.hovered = hovered;
    notifyListeners();
  }

  void rotatePiece(Piece piece) {
    piece = Utils.rotatePiece(piece);
    int pieceIndex = _gamePieces.indexWhere((g) => g.id == piece.id);
    piece.version += 1;
    _gamePieces[pieceIndex] = piece;
    notifyListeners();
  }

  void flipPiece(Piece piece) {
    piece = Utils.flipPiece(piece);
    int pieceIndex = _gamePieces.indexWhere((g) => g.id == piece.id);
    piece.version += 1;
    _gamePieces[pieceIndex] = piece;
    notifyListeners();
  }

//behöver identifiera alla acions man gör i spelet och placera dem i gamestate här och eventuellt skapa utrymme för dem i models
  void putPiece(Piece piece, int x, int y) {
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

    for (int i = 0; i < piece.shape.length; i++) {
      Square square = piece.shape[i];
      square.x += x;
      square.y += y;
    }
    _currentPlayer.board.addPiece(piece);
    _currentPlayer.buttons -= piece.cost;
    _pieceMarkerIndex = _gamePieces.indexWhere((p) => p.id == piece.id);
    _gamePieces.removeAt(_pieceMarkerIndex);
    movePlayerPosition(piece.time);

    //skipa nextTurn ifall att man får en extra tur med gratisbiten
  }

  void extraPiecePlaced(Piece piece, int x, int y) {
    for (int i = 0; i < piece.shape.length; i++) {
      Square square = piece.shape[i];
      square.x += x;
      square.y += y;
    }
    _extraPieceCollected = false;
    _currentPlayer.board.addPiece(piece);

    nextTurn();
  }

  void selectPiece(Piece piece) {}

  void nextTurn() {
    bool gameFinished = RuleEngine.isGameFinished(_players);
    if (gameFinished) {
      _view = "finished";
    }
    _currentPlayer = RuleEngine.getNextPlayer(_players, _currentPlayer);
    //det här neda hör ju också till reglerna?
    List<Piece> cut = _gamePieces.sublist(0, _pieceMarkerIndex);
    List<Piece> newStart = _gamePieces.sublist(_pieceMarkerIndex);
    newStart.addAll(cut);
    _gamePieces = newStart;
    for (int i = 0; i < 3; i++) {
      Piece p = _gamePieces[i];
      p.selectable = RuleEngine.canSelectPiece(p, _currentPlayer);
    }
    notifyListeners();
  }

  void movePlayerPosition(int moves) {
    int before = _currentPlayer.position;
    _currentPlayer.position += moves;
    int after = _currentPlayer.position;
    bool passedButton =
        _timeBoard.buttonIndexes.any((b) => b < after && b > before);
    int passedPieceIndex = _timeBoard.pieceIndexes
        .firstWhere((b) => b < after && b > before, orElse: () => -1);

    if (passedButton) {
      _currentPlayer.buttons += _currentPlayer.board.buttons;
    }
    if (passedPieceIndex > 0) {
      _extraPieceCollected = true;
      _timeBoard.pieceIndexes.removeWhere((p) => p == passedPieceIndex);
    }

    if (after > _timeBoard.goalIndex) {
      _currentPlayer.state = "finished";
      _currentPlayer.position = _timeBoard.goalIndex+1;
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

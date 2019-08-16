import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
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
import 'dart:ui' as ui;
import 'package:patchwork/constants.dart';
import 'package:rxdart/rxdart.dart';

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
  bool _didPass;
  double _bottomHeight;

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
  getBottomHeight() => _bottomHeight;

  double getPatchSelectorHeight() {
    return _bottomHeight - (_boardTileSize * 1.8);
  }

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

  // Future<Null> init() async {
  //   final ByteData data = await rootBundle.load('assets/N.png');
  //   _image = await loadImage(new Uint8List.view(data.buffer));
  //   notifyListeners();
  // }

  // Future<ui.Image> loadImage(List<int> img) async {
  //   final Completer<ui.Image> completer = new Completer();
  //   ui.decodeImageFromList(img, (ui.Image img) {
  //     return completer.complete(img);
  //   });
  //   return completer.future;
  // }

  void restartApp() {
    _view = null;
    _players.clear();
    notifyListeners();
  }

  void setConstraints(double screenWidth, double screenHeight) {
    //varje boardTile ska ha en padding
    double boardTileSpace = screenWidth - (gameBoardInset * 2);
    _boardTileSize = boardTileSpace / _currentBoard.cols;

    _bottomHeight = screenHeight - (screenWidth + (gameBoardInset * 1));

    //notifyListeners(); får error för eveig loop?
  }

  void startQuickPlay() {
    Random rng = new Random();
    addPlayer(
        "Player 1", playerColors[rng.nextInt(playerColors.length)], false);
    List<Color> availablieColors =
        playerColors.where((c) => c != _players[0].color).toList();
    addPlayer("Player 2",
        availablieColors[rng.nextInt(availablieColors.length)], false);

    startGame(GameMode.DEFAULT);
  }

  void startGame(GameMode mode) {
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

  bool isValidPlacement(List<Square> placement) {
    bool isValid = _ruleEngine.validatePlacement(placement, _currentBoard);
    return isValid;
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
    _didPass = false;
    movePlayerPosition(piece.time);

    //skipa nextTurn ifall att man får en extra tur med gratisbiten
  }
  //!todo 1

//https://www.youtube.com/watch?v=s-ZG-jS5QHQ&list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG&index=31 detta för att uppdetar feedback widgeten?

//reordable listview är intressant? för pieceselector, kan vara en pwoer att ändra ordningen
//använd indexedStack istället för en stack med visible widgets i. indexedStack ska behålla state osv men bara visa en i taget

//https://flutter.dev/docs/development/ui/widgets/animation
//https://flutter.dev/docs/development/ui/widgets hitta en widget för announcments

  //kolla in animatedcontainern animatedSwitcher(denna för animaera gameboard in och ut etx?) animated positioned föratt flytta saker. widge of the week

  //
  //animatedlist är cool! använd för addPlayers, pieceSelector? få till så att man ser dismiss på de som försvinnera och de andra som läggs till?
  //behöver sägga till animatedlist vilket index som laggts till eller tagits bort så det animeras. enkelt flr pieceselectorn då alla under _pieceSelectorIndex ska bort behöver inte animera in?
  //i piceselectorn så ha en animated container runt varje patch också? kan den animera card elevation?
//vad mer kan jag använda dessa animationer till? animatedlist för timeboardtiles? övergång för markörer?

  //fixa en dialogruta för när en spelare får 7x7 ska kunna återanvändas till flera announcements. snackbar i värsta fall.
  //om det ska initieras från ruleengine så måste metoden svara med en list<String> announcments? eller skicka med gameState och gameState har en announce()function, eller kan sätta announcement
  //och gameplay eller någon widget läser upp dem i en dialog etc
  //kolla filmer om animation in flutter, kolla flutter cookbook?

  //testa lägg in någon animation. typ när man paserar en button och får pengar. en animation där pengar flyger från boardtiles hasbuttons till cashikonen? typ pieceselector ställer om sig. gameBoard fadar/övergång till nästa spelare, gamepeices rör sig, piece placeras på board

  //börja bygg nya mechanics, börja med att lägga till lootboxes i survivalmode istället för några buttons/pieces. lootboxes kan ha pwoerups eller negativa. kan också enkelt vara +- position,buttons
  // en lootbox är vad man får när man får bingo också?
  //lägg till saxar positiva och negativa
  //ens powers används direkt eller sparas i inventory? som visas mellan selector och timeboard

//ska jag skriva ut hur många steg det är kvar i varje ruta av timeboarddTile? med opacity nere till hörnet varje ruta? förenklar att kolla hur långt fram det är till nästa seplare

  // onWillAccept bryt ut validPlacement till state och vidare till ruleengine. ibland kan det vara valid att överlappa. om man har extra power eller de som överlappar båda har knappar
  // 8. strukturera om filerna. skapa mapp för widgets, eller organisera efter feature/screen?
  //kan jag använda         transform: Matrix4.rotationZ(180) på något sätt för att simpulera rotation/spegling på feedback?
  //det finns ett attribut på text och ikoner jag kan använda för att scala med olika skärmstorlekar. scalfaktorn får vara boardtilesize då. det är standard unit
//jag förösker stänga det med att ta av fokcus men det funkar inte längre.. just nu kör vi en kostsam omräkning av boardTileSize hela tiden för att den inte ska vara null eller minus etc
// vore snygg att få dit sytråden på varje peice när den läggs på bordet https://www.google.com/imgres?imgurl=https%3A%2F%2Fcdn3.volusion.com%2Fqrdkt.xdamu%2Fv%2Fvspfiles%2Fphotos%2FHT12900-2.jpg%3F1551411193&imgrefurl=https%3A%2F%2Fwww.hometrends.ie%2Fpatchwork-multi-print-rug-p%2Fht12900.htm&docid=Hp1AJMBHVw7I8M&tbnid=TzOVMa5Po8fWiM%3A&vet=10ahUKEwjCw8WEsoTkAhVh-ioKHV6HBqUQMwjGASgAMAA..i&w=1080&h=1524&safe=off&bih=984&biw=1924&q=patchwork&ved=0ahUKEwjCw8WEsoTkAhVh-ioKHV6HBqUQMwjGASgAMAA&iact=mrc&uact=8
  //syikoner https://www.visualpharm.com/free-icons/sewing%20button-595b40b75ba036ed117d573a'
  //Pageview är för att scrolla mellan vyer
  //FittedBox för att få till bättre responsivitet? säerkställa att allt syns. eller är det bar tillf ör bilder?

  //https://www.youtube.com/watch?v=ujhKGCBpGtQ den här killen får till feedback realtime udpates med hjälp av streams och rxdart. men han säger också att det ska gå med vanlig statefull setstate..

  // Piece getPieceById(int id) {
  //   Piece p = _gamePieces.firstWhere((p) => p.id == id);

  //   return p;
  // }

  // GameState getInitalState() {
  //   return this;
  // }

  // Stream<GameState> getStreamState() {
  //   var _listController = BehaviorSubject<GameState>.seeded(this);

  //   return _listController.stream;
  // }
//provider class

//output
//   Stream<Piece> get listStream => _listController.stream;

// //input
//   Sink<List<FoodItem>> get listSink => _listController.sink;

//   addToList(FoodItem foodItem) {
//     listSink.add(provider.addToList(foodItem));
//   }

//   removeFromList(FoodItem foodItem) {
//     listSink.add(provider.removeFromList(foodItem));

//   }
// }

  void extraPiecePlaced(Piece piece, int x, int y) {
    for (int i = 0; i < piece.shape.length; i++) {
      Square square = piece.shape[i];
      square.x += x;
      square.y += y;
    }
    cleaHoverBoardTile();
    _extraPieceCollected = false;
    _didPass = false;
    _currentBoard.addPiece(piece);

    nextTurn();
  }

  void _finishGame() {
    _view = "finished";
    _players
        .forEach((player) => player.score = _ruleEngine.calculateScore(player));
    notifyListeners();
  }

  void nextTurn() async {
    //här kollar vi på om någon fått ihop 7x7
    //om personen har det och ingen annan har wonSevenBySeven så får den spelaren det

    //i survival kan jag t.ex kolla om någon fått en bingorad menavvakta med det tills jag kartlagt vilka modes jag ska ha
    _ruleEngine.endOfTurn(this);

    bool gameFinished = _ruleEngine.isGameFinished(_players);
    if (gameFinished) {
      _finishGame();
    }
    Player newPlayer = _ruleEngine.getNextPlayer(_players, _currentPlayer);
    if (newPlayer.id != _currentPlayer.id && !_didPass) {
      await sleep(1);
    }
    _didPass = false;
    _currentPlayer = newPlayer;
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
    //vill ha en sleep eller animation så man ser var piecen hamnar. sleepar jag bara här så har dne inte fått sin position

    notifyListeners();
  }

  Future sleep(int seconds) async {
    for (int i = 0; i < seconds - 1; i++) {
      await new Future.delayed(const Duration(seconds: 1));
    }
    return new Future.delayed(const Duration(seconds: 1));
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
      _currentPlayer.position = _timeBoard.goalIndex;
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
        .reduce((a, b) => a.position > b.position ? a : b)
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
    // _ruleEngine.test(this);
    _didPass = true;

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

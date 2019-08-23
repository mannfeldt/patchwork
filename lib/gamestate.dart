import 'dart:async';
import 'dart:math';
import 'package:patchwork/gameBoard.dart';
import 'package:patchwork/models/announcement.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/lootBox.dart';
import 'package:patchwork/models/lootPrice.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/models/timeBoard.dart';
import 'package:flutter/material.dart';
import 'package:patchwork/defaultGameMechanics.dart';
import 'package:patchwork/patchworkRuleEngine.dart';
import 'package:patchwork/bingoGameMechanics.dart';
import 'package:patchwork/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:patchwork/constants.dart';

class GameState with ChangeNotifier {
  PatchworkRuleEngine _ruleEngine;
  double _boardTileSize;
  Player _currentPlayer;
  Board _currentBoard;
  Piece _draggedPiece;
  bool _extraPieceCollected;
  int _pieceMarkerIndex;
  List<Player> _players = [];
  TimeBoard _timeBoard;
  List<Piece> _gamePieces;
  List<Piece> _nextPieceList;
  String _view;
  bool _didPass;
  double _bottomHeight;
  Announcement _announcement;
  GameBoard _currentGameBoard;
  Player _previousPlayer;
  int _turnCounter;
  bool _recieveButtonsAnimation = false;
  Piece _stopedOnPiece;
  bool _bingoAnimation = false;
  LootBox _lootBox;
  GameMode _gameMode;
  GameState();

  getView() => _view;
  getTimeBoard() => _timeBoard;
  getCurrentPlayer() => _currentPlayer;
  getGamePieces() => _gamePieces;
  getPlayers() => _players;
  getBoardTileSize() => _boardTileSize;
  getExtraPieceCollected() => _extraPieceCollected;
  getDraggedPiece() => _draggedPiece;
  getCurrentBoard() => _currentBoard;
  getBottomHeight() => _bottomHeight;
  getAnnouncement() => _announcement;
  getCurrentGameBoard() => _currentGameBoard;
  getPreviousPlayer() => _previousPlayer;
  getTurnCounter() => _turnCounter;
  getPieceMarkerIndex() => _pieceMarkerIndex;
  getButtonsAnimation() => _recieveButtonsAnimation;
  getBingoAnimation() => _bingoAnimation;
  getLootBox() => _lootBox;
  getGameMode()=> _gameMode;

  void setBingoAnimation(bool bingoAnimation) {
    _bingoAnimation = bingoAnimation;
  }

  double getPatchSelectorHeight() {
    return _bottomHeight - (_boardTileSize * 1.8);
  }

  void setView(String view) {
    _view = view;
    notifyListeners();
  }

  List<Square> getShadow(Square boardTile) {
    List<Square> shadow = Utils.getBoardShadow(_draggedPiece, boardTile);

    //notifyListeners();
    return shadow;
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
      case GameMode.BINGO:
        _ruleEngine = new BingoGameMechanics();
        break;
      default:
        break;
    }
    _gameMode = mode;
    _view = "gameplay";
    _gamePieces = _ruleEngine.generatePieces(_players.length);
    _nextPieceList = _gamePieces;
    _timeBoard = _ruleEngine.initTimeBoard();
    _players = _ruleEngine.initPlayers(_players);
    _pieceMarkerIndex = 0;
    _turnCounter = 0;
    _currentPlayer = _players[0];
    _previousPlayer = _currentPlayer;
    _currentBoard = _currentPlayer.board;
    _currentGameBoard = new GameBoard(board: _currentBoard);
    _extraPieceCollected = false;
    nextTurn();
    notifyListeners();
  }

  void setAnnouncement(Announcement announcement) {
    _announcement = announcement;
    notifyListeners();
  }

  void makeAnnouncement(String title, String text, AnnouncementType type) {
    //kanske ha ett announcement model om det är mer än ett meddelande? kanske ska den ha en tillgörande callback? osv
    setAnnouncement(new Announcement(title, Text(text), type));
  }

  void clearAnnouncement() {
    _announcement = null;
    //notifyListeners();
  }

  bool isValidPlacement(List<Square> placement) {
    bool isValid = _ruleEngine.validatePlacement(placement, _currentBoard);
    return isValid;
  }

  // void updateHoverBoard() {
  //   if (_hoveredBoardTile != null && _draggedPiece != null) {
  //     List<Square> shadow =
  //         Utils.getBoardShadow(_draggedPiece, _hoveredBoardTile);
  //     _boardHoverShadow = shadow;
  //   }
  //   notifyListeners();
  // }

  void rotatePiece(Piece piece) {
    Utils.rotatePiece(piece);
    notifyListeners();
  }

  void flipPiece(Piece piece) {
    Utils.flipPiece(piece);
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

    _draggedPiece = null;
    _currentBoard.addPiece(piece);
    _currentPlayer.buttons -= piece.cost;
    _pieceMarkerIndex = _gamePieces.indexWhere((p) => p.id == piece.id);

    //https://androidkt.com/flutter-listview-animation/
    // jag skapar inte upp keyn helt rätt till att börja med.
    _gamePieces.removeAt(_pieceMarkerIndex);
    _didPass = false;
    bool stop = _ruleEngine.piecePlaced(this);
    if (stop) {
      _currentPlayer.buttons += piece.cost;
      _stopedOnPiece = piece;
      //behöver jag ha detta stop grej ens då handleBingo körs först?
      print("STOP AFTER PIECEPLACES");
      // notifyListeners();
    } else {
      movePlayerPosition(piece.time);
    }

    //skipa nextTurn ifall att man får en extra tur med gratisbiten
  }

  void handleBingo(List<int> bingos) {
    _bingoAnimation = true;
    LootBox lootBox = Utils.getLootBox(bingos.length);
    _currentPlayer.bingos.addAll(bingos);
    _lootBox = lootBox;
    //lootbox består av
    //lista med priser (bättre priser ju högre bingos.length är)
    //id på vilket pris man får
    //sätt lootbox variable här som läses itället för bingoanmimation
    //randoma vinsten från alla priser, randoma ett index mellan x och y och inserta den på den platasen i prislitan
    //sätt sedan lootbox.winning = det indexet

    //i animationen så utgår den ifrån winning id och listan med priser för att animera till vinsten
    //det behöver inte vara direkt på vinsten utan kan animera till pixel inom vinstens constraints
    // när animationen är klar (onforawrd.then) så kallas handleBingoAnimationEnd (döp om till lootbox)
    //som tilldelar priset till spelaren och återgår till vanligt spel
    notifyListeners();

    print("HANDLEBINGO");
  }

  void handleBingoAnimationEnd() {
    int moves = _stopedOnPiece.time;
    _bingoAnimation = false;
    LootPrice win =
        _lootBox.prices.firstWhere((p) => p.id == _lootBox.winningLootId);
    switch (win.type) {
      case LootType.CASH:
        _currentPlayer.buttons += win.amount * _lootBox.valueFactor;
        break;
      case LootType.TIME:
        moves -= win.amount * _lootBox.valueFactor;
        // _currentPlayer.position -= win.amount;
        break;
      default:
    }
    _currentPlayer.buttons -= _stopedOnPiece.cost;
    _lootBox = null;
    _stopedOnPiece = null;
    //TODO 
    // JUST NU FÅR MAN LOOT BARJE GÅNG MAN LÄGGER EN BIT. MÅSTE SE TILL SÅ ATT HANDLEBINGO BARA STARTAS OM MAN FÅR EN MER BINGO ÄN VAD MAN HADE InlineSpan
    // HANTERA OCKSÅ DUBBELBINGO. FÅR BLI EN ANNAN STIL PÅ RUTAN: DET ÄR JU EN ANNAN LOOTBOX
    // LÄGG TILL LOOTBOX VALUE PÅ MODELEN: DEN STYR VÄRDE PÅ PRICES OCH SÅVIDARE

    // STEG 2: LÄGG TILL SÅ ATT SPELPLANEN ÄR 9x8 OCH HA LOOTBOXES LÄNGST UTE TILL HÖGER. IKONER. IKONERNA FÖRSVINNER NÄR MNA FÅR BINGO PÅ DEN RADERN
    // LÄGG TILL DEM I ANIMATIONEN PÅ NÅGOT VIS. ATT DEN ÖPPNAS BARA KANSKE. ELLER FLYGER FRAM TILL DIALOGEN

    //STEG 3: Lägg till animation för att ge ut knappar och tid? ANVÄND IconMovementAnimation
    //regna nerfrån taket bara. eller supermario style att det skjuter upp från golvet och sen landar på golvet
    //forward och reverse alltså
    //för tiden så använd samma nimation fast det är klock-ikoner istället
    //ett nästa steg vore att få till så att det är en klockas visare som snurrar tillbaka ett varv per amount
    //använd callbacken och koppla den till animationcallback och räkna då hur många gånger den ska kallas precis som buttonanimation
    //när den nått alla så är det bara den osynliga kvar som då slår över och stänger hela dialogen
    movePlayerPosition(moves);
  }
  //!todo 1

//lägg till lägg till ikoner för stitches så att man ser tydligare gränser mellan bitar
//lägg in animation för att dela upp pengar till spelaren när den pacerar en button. får göras på liknande sätt som jag animerar scroll på patchselectorn?
//alltså behöver kanske en sleep i gamestate? behöver iaf en buttonsToRecieve paramter
//Får tänka som extrapiece vad som händer där. och göra på samma sätt för animationen. bara att den går vidare till nextTurn automatiskt efter x antal minuter.
//tänk på vad som händer om man går förbi både pengar och bricka samtidigt. man ska gå vidare till att få sela extrabiten efter animationen eller ja animationen ska kunna seplas
//medan extra biten visas helt enkelt

  //BINGO kan ha en mindrek kolumn. så gameboard är 8x9 och den saknade kolumnen ersätts med lootboxes
//börja med bing och lootboxes till höger kolumnen
//animated postion för reveal av lootbox? eller ska det ske i en dialog som en acual lootbox där det scrollas och sen stannar på något som man får??

//det blir mycket inblandata i gamestate och model som är specifkt för ett gamemode? skapa specifika modeler som ärver? för widgetar också?
// bingoBoard extends board. bingoPlayer extens player etc.

  //börja bygg nya mechanics, börja med att lägga till lootboxes i survivalmode istället för några buttons/pieces. lootboxes kan ha pwoerups eller negativa. kan också enkelt vara +- position,buttons
  // en lootbox är vad man får när man får bingo också?
  //lägg till saxar positiva och negativa
  //ens powers används direkt eller sparas i inventory? som visas mellan selector och timeboard

//reordable listview är intressant? för pieceselector, kan vara en pwoer att ändra ordningen
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
    _extraPieceCollected = false;
    _draggedPiece = null;
    _didPass = false;
    _currentBoard.addPiece(piece);
    nextTurn();
    cleaPieceMarkerIndex(false);
  }

  void _finishGame() {
    _view = "finished";
    _players
        .forEach((player) => player.score = _ruleEngine.calculateScore(player));
    _announcement = null;
    notifyListeners();
  }

  void nextTurn() {
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
      //await sleep(1);
    }
    if (newPlayer.id != _currentPlayer.id) {
      _turnCounter += 1;
      _previousPlayer = _currentPlayer;
      //await sleep(1);
    }
    _didPass = false;
    _currentPlayer = newPlayer;
    _currentBoard = _currentPlayer.board;
    _currentGameBoard = new GameBoard(board: _currentBoard);

    //det här neda hör ju också till reglerna?
    if (_pieceMarkerIndex > -1) {
      List<Piece> cut = _gamePieces.sublist(0, _pieceMarkerIndex);
      List<Piece> newStart = _gamePieces.sublist(_pieceMarkerIndex);
      newStart.addAll(cut);
      _nextPieceList = newStart;
    }
    for (int i = 0; i < 3; i++) {
      Piece p = _nextPieceList[i];
      p.selectable = _ruleEngine.canSelectPiece(p, _currentPlayer);
    }
    notifyListeners();
  }

  void clearAnimationButtons(bool goSleep) async {
    _recieveButtonsAnimation = false;
    _currentPlayer.buttons += _currentBoard.buttons;
    if (_extraPieceCollected) {
      notifyListeners();
    } else {
      nextTurn();
    }
  }

  void cleaPieceMarkerIndex(bool goSleep) async {
    if (goSleep) {
      await sleep(500);
    }
    _pieceMarkerIndex = -1;
    _gamePieces = _nextPieceList;
    notifyListeners();
  }

  Future sleep(int ms) async {
    return new Future.delayed(Duration(milliseconds: ms));
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
      //jag kan göra en animation i denna dialog? stateful dialog. som tar playerobjekt utfrån det kan jag hämta board.buttons player.buttons player.name osv
      _recieveButtonsAnimation = true;
      //lyssna på denna som om det vore en announcement i gamePlayer
      //och visa detta
      //samma sätt kommer jag göra med lootboxes?
      //det är bara visuellt. ingen effekt? ser det konstigt ut? för om man går förbi en och direkt får in det på cash nedan och sen kommer animationen
      // jag vill ju helt ha att animationen är att buttons kommer från boardTiles som hasBUtton till spelaren kan jag göra det istället?
      //gör det till spelarn på timeboardet
      //kanske måste frysa tidne i väntan på animeringen är klar då? iståfall blir det en lösing liknande extrapiece/patchselectorn
      //ULTIMATLY. tänk på hur jag vill göra med lootboxes för detta kan bli liknande? lootbox vill jag ha i en dialog. där är väl enkalst att göra nu också?

      //här!
      // nu verkar det funera med button recieved alert. Men duger det? Testa lägg till en bingoAlert. går ju enkelt att göra då jag har logiken klar.
      // hållbart sätt att hantera animationer o dialoger? om jag lägger Consumer widget runt saker ostället för provder of så blir inte hela widgeten nofifierad varje gång?
      // använd en klick i dialogen eller på en knapp som action för att gå vidare. undvik sleep osv.toString()
      // för buttonanimation reciever så använd animatedposition och animatedTextStyle? för någt coolt. lägg hela i en egen stateful widget? hur får jag till detta?
      // kan hitta på en startpos och en slutpos men hur animerar jag det? en animationController? hur startar jag allt. initstate?
      // googla på exempel på animationer som startar automatiskt
      // JAG KAN GÖRA CONTROLLER.forward() direkt i builern
      // https://www.youtube.com/watch?v=dNSteCm-cEY 39.00

      //jag fr testa lite olika. börj amed att testa om jag kan animera position av iconer från boardtiles hasbuttons till en player. player ikons och namn och score visas över gameboard och buttons dras till pengarna somtickar uppåt
      //alternativet är att ha en dialog där det

      // setAnnouncement(new Announcement(
      //     "",
      //     Text(_currentPlayer.name +
      //         " recieved " +
      //         _currentBoard.buttons.toString() +
      //         " buttons"),
      //     AnnouncementType.simpleDialog));
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
      setAnnouncement(new Announcement(
          "",
          Text(_currentPlayer.name + " crossed the goal line"),
          AnnouncementType.simpleDialog));
    }
    if (_extraPieceCollected) {
      if (_pieceMarkerIndex > -1) {
        List<Piece> cut = _gamePieces.sublist(0, _pieceMarkerIndex);
        List<Piece> newStart = _gamePieces.sublist(_pieceMarkerIndex);
        newStart.addAll(cut);
        _nextPieceList = newStart;
      }
      for (int i = 0; i < 3; i++) {
        Piece p = _nextPieceList[i];
        p.selectable = _ruleEngine.canSelectPiece(p, _currentPlayer);
      }
      cleaPieceMarkerIndex(false);
    } else if (_recieveButtonsAnimation) {
      //denna kod är duplicerad på tre ställen... behövs den överallt?
      if (_pieceMarkerIndex > -1) {
        List<Piece> cut = _gamePieces.sublist(0, _pieceMarkerIndex);
        List<Piece> newStart = _gamePieces.sublist(_pieceMarkerIndex);
        newStart.addAll(cut);
        _nextPieceList = newStart;
      }
      for (int i = 0; i < 3; i++) {
        Piece p = _nextPieceList[i];
        p.selectable = _ruleEngine.canSelectPiece(p, _currentPlayer);
      }
      notifyListeners();
    } else {
      nextTurn();
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
    _pieceMarkerIndex = -1;

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

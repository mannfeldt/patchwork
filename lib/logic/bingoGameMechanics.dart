import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/logic/gamestate.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/models/timeBoard.dart';
import 'package:patchwork/utilities/pieceGenerator.dart';
import 'package:patchwork/logic/patchworkRuleEngine.dart';
import 'package:patchwork/utilities/utils.dart';

class BingoGameMechanics implements PatchworkRuleEngine {
  @override
  bool isGameFinished(List<Player> players) {
    return players.every((p) => p.state == "finished");
  }

  @override
  int calculateScore(Player player) {
    int missingTiles = Utils.emptyBoardSpaces(player.board);
    int score = player.buttons - (missingTiles * 2);
    return score;
  }

  @override
  bool canSelectPiece(Piece piece, Player player) {
    if (piece.cost > player.buttons) return false;
    return true;
  }

  @override
  List<Piece> generatePieces(int noOfPlayers) {
    List<Piece> pieces = [];
    int stacksOfPieces = (noOfPlayers / 2).round();
    for (int i = 0; i < stacksOfPieces; i++) {
      pieces.addAll(PieceGenerator.getBingoModePieces(40));
    }
    pieces.shuffle();
    return pieces;
  }

  @override
  Player getNextPlayer(List<Player> players, Player currentPlayer) {
    int lastPosition =
        players.reduce((a, b) => a.position < b.position ? a : b).position;
    List<Player> lastPlayers =
        players.where((p) => p.position == lastPosition).toList();
    if (lastPlayers.length > 1 && lastPlayers.contains(currentPlayer))
      return currentPlayer;
    return lastPlayers[0];
  }

  @override
  bool validatePlacement(List<Square> placement, Board board) {
    bool isOutOfBounds = Utils.isOutOfBoardBounds(placement, board);
    if (isOutOfBounds) return false;

    bool fitsOnBoard = Utils.hasRoom(placement, board);
    return fitsOnBoard;
  }

  @override
  TimeBoard initTimeBoard() {
    return new TimeBoard.bingo();
  }

  @override
  List<Player> initPlayers(List<Player> players) {
    players.forEach((p) => p.buttons = bingoStartButtons);
    players.forEach((p) => p.board.cols = 8);

    return players;
  }

  @override
  bool piecePlaced(GameState gameState) {
    //gör om detta med bingo!! samma färg. BYT UT FÄRG TILL IMAGESRC?
    Player currentPlayer = gameState.getCurrentPlayer();
    List<int> bingos = Utils.getBingoRows(currentPlayer.board);
    List<int> newBingos =
        bingos.where((b) => !currentPlayer.bingos.contains(b)).toList();
    if (newBingos.length > 0) {
      //det här ska vara en speciel dialog som är lootbox
      //istället för flera lootboxes så om man får dubbelbingo, alltså bingo på två rader samtidigt så får man en bättre lootbox
      // ska skicka in raden till dialogen så att den kan ta lootboxen från rätt position. öppna upp den på något vis
      //starta den här lootbox animeringen som är som cs:go, använd kanske en lista med loots och placera i animatedList
      //använd animateTo random int. med någon snygg curve. när animeringen är klar. alltså on forward.then

      //då kallar vi på en metod i state liknande som för buttonAnimeringen som återgår till spelet.
      //skillnaden är att den metoden i state tar emot vilken loot det resulterade i och applicerar det direkt eller
      //sparar undan det till playern. player kommer ha en player.powerups etc?
      //power ups får visa som en inventory typ. som man kna klicka på som då visar en lista med sina power ups som man kan klicka på för att aktivera
      //kanske bara en buttonlist som i setup med gamemode i enklaste fall? fast vill gärna ha något mer som riktigt inventory
      //med bra och dåliga saker sorterade

      //ska frysa spelet så inte nextturn körs. detta bingo grejs ska ju inte ligga efter varje turn utan efter varje piecePlaced
      //
      gameState.handleBingo(newBingos);
      return true;
    }
    return false;
  }

  @override
  void endOfTurn(GameState gameState) {}
}

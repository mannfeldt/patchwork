import 'dart:math';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/pieceGenerator.dart';
import 'package:patchwork/utils.dart';

class RuleEngine {
  static List<Piece> generatePieces() {
    //jag kan använda en mig av utils.default och randomly generated pieces så att det blir spelbart
    //en slider för hur stor del som ska vara random och hur stor del default pieces
    //jag kan ha bådede defaultpireces och en originalPieces där jag skapat egna bitar som är lite roliga
    //ha en skön blandning av detta. se till i slutänden att ha rätt ratio av sizes på bitarna
    //blir kanske en metod för det? kanske ser till att lägga lite extra bitar och sen får de tas bort
    //eller så förlitar jag mig på veto-ideen om att spelarna får välja bort bitar innan start

    List<Piece> pieces = PieceGenerator.getDefaultPieces();
    //List<Piece> pieces = PieceGenerator.getRandomPieces(40);


    return pieces;
  }

  static bool validatePlacement(Piece piece, Board board, int x, int y) {
    //validerar om piece kan placeras på board vid postion x,y
    //x,y är leftTopMostSquare of the piece
  }

  static bool canSelectPiece(Piece piece, Player player) {
    if (piece.cost > player.buttons) return false;
    return true;

    //kollar att spelaren har tillräckligt med buttons för att köpa piecen
    //kanske också kolla om piecen kan placeras nåonstanns på player.board? eller är det lite fusk?
  }

  static Player getNextPlayer(List<Player> players, Player currentPlayer) {
    int lastPosition =
        players.reduce((a, b) => a.position < b.position ? a : b).position;
    List<Player> lastPlayers =
        players.where((p) => p.position == lastPosition).toList();
    if (lastPlayers.length > 1 && lastPlayers.contains(currentPlayer))
      return currentPlayer;
    return lastPlayers[0];
    //returnera playerid på vems tur det är
    //det är den som har lägst position
    //om de har lika så returnera currentPlayerId tror jag. borde fungera även på mutliple players?
    //det kan ju aldrig vara två på samma plats utan att den precis landat där och då får ju den fortsätta

    //använd reduce? eller vanlig for loop?
  }

  static bool isGameFinished(List<Player> players) {
    return players.every((p) => p.state == "finished");
  }

  static int calculateScore(Player player) {
    int missingTiles =
        (player.board.cols * player.board.rows) - player.board.squares.length;
    int score = player.buttons - (missingTiles * 2);
    return score;
  }
}

void main() {
  List<Piece> ps = RuleEngine.generatePieces();
  for (int k = 0; k < ps.length; k++) {
    Piece p = ps[k];
    List<String> s = p.getVisual();
    for (int i = 0; i < s.length; i++) {
      if (s[i].length > 0) {
        //print(s[i]);
      }
    }
    //print("-------------------");
  }
}

import 'dart:math';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/constants.dart';

class RuleEngine {
  static List<Piece> generatePieces() {
    List<Piece> pieces = [];
    //jag kan använda en mig av utils.default och randomly generated pieces så att det blir spelbart
    //en slider för hur stor del som ska vara random och hur stor del default pieces
    //jag kan ha bådede defaultpireces och en originalPieces där jag skapat egna bitar som är lite roliga
    //ha en skön blandning av detta. se till i slutänden att ha rätt ratio av sizes på bitarna
    //blir kanske en metod för det? kanske ser till att lägga lite extra bitar och sen får de tas bort
    //eller så förlitar jag mig på veto-ideen om att spelarna får välja bort bitar innan start

    //RANDOM SHAPES
    // for (int i = 0; i < 100; i++) {
    // Piece p = new Piece.random(pieces.length);
    //   pieces.add(p);
    // }

    //TAKES DEFAULT SHAPES AND USES ALGORITM TO CALCULATE REST
    // for(int i = 0; i<Constants.defaultPieces2.length; i++){
    //   List<String> visualPiece = Constants.defaultPieces2[i]["visual"];
    //   Piece p = new Piece.fromVisual(pieces.length, visualPiece);
    //   pieces.add(p);
    // }

    // STRAIGT DEFAULT PIECES
    for (int i = 0; i < Constants.defaultPieces.length; i++) {
      var piece = Constants.defaultPieces[i];
      Piece p = new Piece(pieces.length, piece['visual'], piece['buttons'],
          piece['cost'], piece['time']);
      pieces.add(p);
    }

   

    // pieces.add(new Piece.fromVisual(pieces.length, [
    //   "[0][0][0][0][0][0][0][0][0]",
    //   "[0][0][0][0][0][0][0][0][0]",
    //   "[0][0][0][0][0][0][0][0][0]",
    //   "[0][0][X][X][X][X][0][0][0]",
    //   "[0][0][X][X][X][X][0][0][0]",
    //   "[0][0][X][X][X][X][0][0][0]",
    //   "[0][0][0][0][0][0][0][0][0]",
    //   "[0][0][0][0][0][0][0][0][0]",
    //   "[0][0][0][0][0][0][0][0][0]"
    // ]));

    for (int k = 0; k < pieces.length; k++) {
      Piece p = pieces[k];
      print("cost adjustment: " + p.costAdjustment);
      print("buttons: " +
          p.buttons.toString() +
          " cost: " +
          p.cost.toString() +
          " time: " +
          p.time.toString());
      print("difficulty: " + p.difficulty.toString());
      p.render(p.getVisual());
      print("------------------------");
    }

    return pieces;
  }

  static bool validatePlacement(Piece piece, Board board, int x, int y) {
    //validerar om piece kan placeras på board vid postion x,y
    //x,y är leftTopMostSquare of the piece
  }

  static bool canSelectPiece(Piece piece, Player player) {
    //kollar att spelaren har tillräckligt med buttons för att köpa piecen
    //kanske också kolla om piecen kan placeras nåonstanns på player.board? eller är det lite fusk?
  }

  static int getNextPlayerIndex(List<Player> players, int currentPlayerId) {
    //returnera playerid på vems tur det är
    //det är den som har lägst position
    //om de har lika så returnera currentPlayerId tror jag. borde fungera även på mutliple players?
    //det kan ju aldrig vara två på samma plats utan att den precis landat där och då får ju den fortsätta

    //använd reduce? eller vanlig for loop?
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

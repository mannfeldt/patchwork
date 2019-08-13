import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/square.dart';
class Board {
  int buttons;
  List<Piece> pieces;
  List<Square> squares;
  int rows;
  int cols;

  Board(){
    this.buttons =0;
    this.rows = 9;
    this.cols = 9;
    this.pieces = [];
    this.squares = [];
  }
  void addPiece(Piece piece){

    this.pieces.add(piece);
    this.squares.addAll(piece.shape);
    this.buttons += piece.buttons;
    
    //lägger till piecen i listan. koordinaterna är redan uträknade i gamestate
    //adderar piecens buttons till this.buttons
    
  }
}

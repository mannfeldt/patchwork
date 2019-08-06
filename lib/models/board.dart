import 'package:patchwork/models/piece.dart';
class Board {
  int buttons;
  List<Piece> pieces;
  int maxY;
  int maxX;

  Board(){
    this.buttons =0;
    this.maxY = 8;
    this.maxX = 8;
  }
  void addPiece(Piece piece){
    //lägger till piecen i listan. koordinaterna är redan uträknade i gamestate
    //adderar piecens buttons till this.buttons
    
  }
}

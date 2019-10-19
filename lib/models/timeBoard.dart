class TimeBoard {
  List<int> buttonIndexes;
  List<int> pieceIndexes;
  List<int> wildCardIndexes;
  List<int> scissorsIndexes;
  int goalIndex;

  TimeBoard() {
    this.goalIndex = 70; //ska vara vad? återsätll heal denna fil sen
    this.buttonIndexes = [];
    this.pieceIndexes = [26, 32, 38, 44, 50];
    this.scissorsIndexes = [];
  }
  TimeBoard.bingo() {
    this.goalIndex = 60;
    this.buttonIndexes = [];
    this.pieceIndexes = [];
    this.scissorsIndexes = [13, 20, 26, 34];
  }
}

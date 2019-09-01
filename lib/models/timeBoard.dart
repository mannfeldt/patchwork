class TimeBoard {
  List<int> buttonIndexes;
  List<int> pieceIndexes;
  List<int> wildCardIndexes;
  List<int> scissorIndexes;
  int goalIndex;

  TimeBoard() {
    this.goalIndex = 53;
    this.buttonIndexes = [5, 11, 17, 23, 29, 35, 41, 47, 53];
    this.pieceIndexes = [26, 32, 38, 44, 50];
    this.scissorIndexes = [];
  }
  TimeBoard.bingo() {
    this.goalIndex = 40;
    this.buttonIndexes = [4, 10, 16, 22, 30, 38];
    this.pieceIndexes = [];
    this.scissorIndexes = [13, 20, 26, 34];
  }
}

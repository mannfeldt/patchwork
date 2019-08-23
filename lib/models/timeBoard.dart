class TimeBoard {
  List<int> buttonIndexes;
  List<int> pieceIndexes;
  List<int> wildCardIndexes;
  int goalIndex;

  TimeBoard() {
    this.goalIndex = 53;
    this.buttonIndexes = [5, 11, 17, 23, 29, 35, 41, 47, 53];
    this.pieceIndexes = [26, 32, 38, 44, 50];
  }
  TimeBoard.bingo() {
    this.goalIndex = 60;
    this.buttonIndexes = [4, 10, 16, 22, 30, 38, 46, 54];
    this.pieceIndexes = [26, 34, 42, 50];
    this.wildCardIndexes = [20, 36];
  }
}

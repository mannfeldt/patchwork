class TimeBoard {
  List<int> buttonIndexes;
  List<int> pieceIndexes;
  List<int> wildCardIndexes;
  int goalIndex;

  TimeBoard(String type) {
    switch (type) {
      case "default":
        this.goalIndex = 53;
        this.buttonIndexes = [5, 11, 17, 23, 29, 35, 41, 47, 53];
        this.pieceIndexes = [26, 32, 38, 44, 50];
        break;
      case "wild":
        //differend mode,
        this.goalIndex = 70;
        this.buttonIndexes = [5, 11, 17, 24, 31, 38, 45, 52, 59, 66];
        this.pieceIndexes = [34, 42, 49, 56];
        this.wildCardIndexes = [20, 36, 69];
        break;
    }
  }
}


class TimeBoard {
  List<int> buttonIndexes;
  List<int> pieceIndexes;
  List<int> scissorIndexes;
  int goalIndex;

  TimeBoard(String type) {
    switch (type) {
      case "default":
        this.goalIndex = 30;
        this.buttonIndexes = [6,11,16,23,29];
        this.pieceIndexes = [9,19,25];
        break;
      case "wild":
      //differend mode, 
        this.goalIndex = 40;
        this.buttonIndexes = [6,11,16,23,29,39];
        this.pieceIndexes = [9,19,25];
        this.scissorIndexes = [13, 33];
        break;
    }
  }
}

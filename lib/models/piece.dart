import 'dart:math';
import 'package:flutter/material.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/utils.dart';

class Piece {
  int id;
  int size;
  int buttons;
  List<Square> squares;
  int cost;
  int time;
  Color color;
  int difficulty;
  String costAdjustment; // 10SALE, 20SALE, 30SALE, 10OVER, 20OVER, 30OVER
  String state; // active, selectable, unselectable, used

  Piece(int id) {
    this.id = id;
    this.state = "active";
    this.size = _getSize();
    this.squares = _getSquares(this.size);
    //this.buttons = _getButtons(this.size);
    this.buttons = 0;
    // //ska kosta 1button 5times
    // this.buttons = 1;
    // this.squares = [
    //   new Square(0, 0),
    //   new Square(1, 0),
    //   new Square(1, 1),
    //   new Square(1, 2),
    //   new Square(1, 3),
    //   new Square(0, 3)
    // ];

    // //ska kosta 1button 5times
    // this.buttons = 1;
    // this.squares = [
    //   new Square(0, 0),
    //   new Square(1, 0),
    //   new Square(1, 1),
    //   new Square(1, 2),
    //   new Square(1, 3),
    //   new Square(0, 3)
    // ];

    // //ska kosta 2buttons 2time
    // this.buttons = 0;
    // this.squares = [
    //   new Square(0, 0),
    //   new Square(0, 1),
    //   new Square(1, 1),
    //   new Square(1, 2),
    //   new Square(0, 2),
    // ];

    // //ska kosta 2buttons 2time
    // this.buttons = 0;
    // this.squares = [
    //   new Square(0, 0),
    //   new Square(1, 0),
    //   new Square(2, 0),
    // ];

    // //ska kosta 2buttons 1time
    // this.buttons = 0;
    // this.squares = [
    //   new Square(0, 0),
    //   new Square(1, 0),
    // ];

    // //ska kosta 1buttons 3time men också 3button 1time
    // this.buttons = 0;
    // this.squares = [
    //   new Square(0, 0),
    //   new Square(0, 1),
    //   new Square(1, 1),
    // ];

    //ska kosta 2buttons 2time
    // this.buttons = 0;
    // this.squares = [
    //   new Square(0, 0),
    //   new Square(0, 1),
    //   new Square(1, 1),
    //   new Square(0, 2),
    // ];

    // //ska kosta 1buttons 2time
    // this.buttons = 0;
    // this.squares = [
    //   new Square(0, 0),
    //   new Square(0, 1),
    //   new Square(1, 0),
    //   new Square(0, 2),
    //   new Square(1, 2),
    // ];

    // //ska kosta 1buttons 2time
    // this.buttons = 0;
    // this.squares = [
    //   new Square(0, 0),
    //   new Square(1, 0),
    //   new Square(1, 1),
    //   new Square(1, 2),
    //   new Square(1, 3),
    //   new Square(2, 3),
    // ];

    //ska kosta 4buttons 2time
    // this.buttons = 0;
    // this.squares = [
    //   new Square(0, 0),
    //   new Square(0, 1),
    //   new Square(1, 1),
    //   new Square(0, 2),
    //   new Square(1, 2),
    //   new Square(1, 3),
    // ];

    // //ska kosta 2buttons 1time
    // this.buttons = 0;
    // this.squares = [
    //   new Square(0, 1),
    //   new Square(1, 0),
    //   new Square(1, 1),
    //   new Square(2, 1),
    //   new Square(3, 1),
    //   new Square(2, 2),
    // ];

    //ska kosta 5
    // this.buttons = 0;
    // this.squares = [
    //   new Square(0, 0),
    //   new Square(2, 0),
    //   new Square(0, 1),
    //   new Square(1, 1),
    //   new Square(2, 1),
    //   new Square(0, 2),
    //   new Square(2, 2),
    // ];

    this.difficulty = _getDificulty(this.squares);
    this.color = _getColor();
    _setCost();

    print("buttons: " +
        this.buttons.toString() +
        " cost: " +
        this.cost.toString() +
        " time: " +
        this.time.toString());
    print("difficulty: " + this.difficulty.toString());
    render(getVisual());
  }

  Color _getColor() {
    var rng = new Random();
    int colorIndex = rng.nextInt(Utils.pieceColors.length);
    Color color = Utils.pieceColors[colorIndex];
    return color;
  }

  int _getSize() {
    //skulle kunna ta in befintliga peices och avgöra chanserna lite baserat på det.
    //alltså om det är ett högt medel på befntliga så lutar vi mer åt att skapa en lägre och lika åt andra hållet
    var rng = new Random();
    int num = rng.nextInt(100);
    if (num < 5) return 2;
    if (num < 5 + 8) return 3;
    if (num < 13 + 9) return 4;
    if (num < 22 + 11) return 5;
    if (num < 33 + 12) return 6;
    if (num < 45 + 13) return 7;
    if (num < 58 + 12) return 8;
    if (num < 70 + 11) return 9;
    if (num < 81 + 9) return 10;
    if (num < 90 + 6) return 11;
    return 12;
  }

  int _getButtons(int size) {
    var rng = new Random();
    int num = rng.nextInt(100);
    int max = size - 1;
    if (num < 30) return 0;
    if (num < 30 + 20) return 1;
    if (num < 50 + 20) return min(max, 2);
    if (num < 70 + 15) return min(max, 3);
    if (num < 85 + 11) return min(max, 4);
    return min(max, 5);
  }

  List<Square> _cropPiece(List<Square> squares) {
    int minY = squares.reduce((a, b) => a.y < b.y ? a : b).y;
    int minX = squares.reduce((a, b) => a.x < b.x ? a : b).x;

    List<Square> croppedSquares = [];
    croppedSquares.addAll(squares);

    while (minY > 0) {
      croppedSquares =
          croppedSquares.map((s) => new Square(s.x, s.y - 1)).toList();
      minY = croppedSquares.reduce((a, b) => a.y < b.y ? a : b).y;
    }
    while (minX > 0) {
      croppedSquares =
          croppedSquares.map((s) => new Square(s.x - 1, s.y)).toList();
      minX = croppedSquares.reduce((a, b) => a.x < b.x ? a : b).x;
    }
    return croppedSquares;

//not needed if i start att 0,0

    // let scaledSquares = [...squares];
    // let minY = squares.reduce((a,b) => a.y < b.y ? a : b).y;

    // while(minY > 0){
    //    scaledSquares = scaledSquares.map(s => {x: s.x, y: s.y-1});
    //    minY = scaledSquares.reduce((a,b) => a.y < b.y ? a : b).y;
    // }
    // return scaledSquares;
    //se till så att bitarna lägger sig så lång upp till vänster som möjligt.
    //alltså ta minus 1 på alla cordinater tills någon slår i kanten
  }

  int _getDificulty(List<Square> squares) {
    List<Square> searchable = [];
    List<Square> actual =
        squares.map((s) => new Square(s.x + 1, s.y + 1)).toList();
    int maxY = actual.reduce((a, b) => a.y > b.y ? a : b).y;
    int maxX = actual.reduce((a, b) => a.x > b.x ? a : b).x;
    int minY = actual.reduce((a, b) => a.y < b.y ? a : b).y;
    int minX = actual.reduce((a, b) => a.x < b.x ? a : b).x;

    // print("maxY:" + maxY.toString());
    // print("maxX:" + maxX.toString());
    for (int curY = 0; curY < maxY + 2; curY++) {
      for (int curX = 0; curX < maxX + 2; curX++) {
        Square s = new Square(curX, curY);
        searchable.add(s);
      }
    }
    //nu har jag nog en fungerande searchable grid. som täcker in hela squares
    //loopa igenom searchables och kolla mot squares om det är en tom ruta så gör kollen på hur många grannar den har i squares.
    //så börja göra loopen och räkningen av grannar. eller vänta. jag behöver ju inte göra searcjables över och till vänster..

    // print("------searchable-----");
    // render(_getVisual(searchable));
    // print("maxY:" + maxYResult.toString());
    // print("maxX:" + maxXResult.toString());

    int difficulty = 0;
    List<Square> multipleNeighbors = [];
    for (int i = 0; i < searchable.length; i++) {
      Square square = searchable[i];
      bool exists = actual.any((s) => s.y == square.y && s.x == square.x);
      if (!exists) {
        int neighbors = _countNeighbors(square, actual);

        if (neighbors == 1) difficulty += 1;
        if (neighbors == 2) difficulty += (6 + squares.length / 3).round();
        if (neighbors == 3) difficulty += (10 + squares.length / 3).round();
        if (neighbors == 4) difficulty += (18 + squares.length / 3).round();

        if (neighbors > 1) {
          multipleNeighbors.add(square);
        }
      }
    }
    //check for stairs or other extreme occorances
    for (int i = 0; i < multipleNeighbors.length; i++) {
      Square current = multipleNeighbors[i];
      //kan jag kolla om den har någon annan som är nordväst eller nordost? om den har en granne som är sydost eller sydväst så kollas ju det på denne senare
      bool hasNorthWest = multipleNeighbors
          .any((s) => s.x == current.x - 1 && s.y == current.y - 1);
      bool hasNorthEast = multipleNeighbors
          .any((s) => s.x == current.x + 1 && s.y == current.y - 1);
      if (hasNorthEast) difficulty += 18;
      if (hasNorthWest) difficulty += 18;
    }
    difficulty += multipleNeighbors.length*2;

    if (squares.length > 4) {
      int spreadRatio = (maxX - minX) * (maxY - minY);
      int sizeToSpreadRatio = spreadRatio - (squares.length - 2);
      difficulty += (spreadRatio + (min(2, sizeToSpreadRatio))) * 2;
      if (((spreadRatio + sizeToSpreadRatio) * 2) < 0) {
        //har så blir spread till att sänka deiff. är det bra? kolla vilka som kan hamnar här och vad som händer med dem. väldigt få fall
      }

      //print("SPREAD " + spreadRatio.toString());
    }

    return difficulty - 4;

    //skapa en lista med squares som går från 0,0 till squares.maxY +1, squares.maxX+1
    //loppa igenom alla squares i den listan
    //om squaren inte finns i inparametern(squares) så betyder det är det är en "tom" ruta
    //kolla då hur många grannar den toma rutan har. north, south, east, west. svaret blir 0-4 där 0 är att den inte har några grannar, 4 så är det ett hål
    //1 så är det längs ett sträck, 2 så är det ett hörn eller mellan två parallella, 3 så är det en "vik"

    //ge varje antal granne en svårigethsgrad. t.ex. 4 grannar = 10, 3 grannar = 6, 2 grannar = 3, 1 granne = 1, 0 granne = 1(2?)
    //skapa ett objekt eller en map för att hålla information om grannar till value ratio
    //får göra massa tester och tweaka efterhand
    //använd ett medelvärde (devided by size) or total value?
  }

  int _countNeighbors(Square square, List<Square> possibleNeighbors) {
    int neighbors = 0;
    for (int i = 0; i < possibleNeighbors.length; i++) {
      Square possibleNeighbor = possibleNeighbors[i];
      for (Square direction in Utils.directions) {
        if (possibleNeighbor.y == (square.y + direction.y) &&
            possibleNeighbor.x == (square.x + direction.x)) {
          neighbors += 1;
        }
      }
    }
    return neighbors;
  }

  List<Square> _getSquares(int size) {
    List<Square> squares = [];

    var rng = new Random();
    int startX = rng.nextInt(7);
    int startY = rng.nextInt(7);
    Square startSquare = new Square(startX, startY);
    squares.add(startSquare);
    while (squares.length < size) {
      Square latest = squares[squares.length - 1];
      Square direction =
          Utils.directions[rng.nextInt(4)]; //behövs floor på random?
      Square newSquare =
          new Square(latest.x + direction.x, latest.y + direction.y);
      if (_outOfBounds(newSquare)) {
        continue;
      }
      squares.removeWhere((s) => s.x == newSquare.x && s.y == newSquare.y);
      squares.add(newSquare);
    }
    
    return _cropPiece(squares);
    //   while(squares.length < size){
    //     let latestSquare = squares[squares.length-1];
    //     let direction = directions[Math.floor(Math.random() * 4)];
    //     let newSquare = {
    //       x: latestSquare.x + direction.x,
    //       y: latestSquare.y + direction.y
    //     };
    //     if(outOfBounds(newSquare)){
    //       continue;
    //     }
    //     let existingSquare = squares.findIndex(s=> s.x===newSquare.x && s.y===newSquare.y);
    //     if(existingSquare > -1){
    //         squares.splice(existingSquare, 1);
    //     }
    //     squares.push(newSquare);

    //   }
    // return scaleSquares(squares);
  }

  void _setCost() {
    //baserat på squares och buttons så räkna ut ett värde.
    //ju komapktare det är desto bättre är biten troligen. och om den har hål är den värdelös nästan.
    //kolla mina andra kommentarer för hur jag garderar bitar efter svårgihetsgrad..

    //jag tänkar att man börjar tänka på de små enkla bitarna. kolla vad de kostar i riktiga spelet och sen lägga till en faktor för difficulty
    //kanske ta difficulty -5 eller något för att inte räkn allt för många låga värden. eller det gör jag ju inte här utan i berälningen av diff
    int buttonFactor = (this.buttons * 2);
    int sizeFactor = (this.squares.length * 1.2).floor() + 1;
    int diffFactor = (this.difficulty / 9).round();
    int totalCost = buttonFactor + sizeFactor - diffFactor;

    //är 1 time lika kostsamt som 1 button? kolla på riktiga spelet och avgör om det verkar stämma. liknande bitar med olika ratio?
    if (squares.length == 3) {
      totalCost = max(4, totalCost); //0-10 eller 15 kanske
    } else {
      totalCost = max(3, totalCost); //0-10 eller 15 kanske
    }

    //buttons och time är lika mycket värde. får ha en radnom genererare som generar random antal time vs buttons
    //ska det kunna variera +1 eller -1 också? det kan vara fyndvaror och överpris. bitarna markeras med en prispoint då
    // kan även vara +2 eller -2 om det gäller brickor som har en cost på över 10. ge alltså en 20% rabbat floor. *.2.floor()?
    //30,20,10% rea. round(). 10/20/30 svindel/scam/överpris. Lite högre chans att hitta rea än scam.
    //fokusera på bra bud på stora bitar. därav %. avrunda åt något bra håll.

    Random rng = new Random();
    int num = rng.nextInt(100);
    //detta är bara buttons cost inte time
    this.costAdjustment = "NONE";
    if (num < 4) this.costAdjustment = "SALE30";
    if (num < 4 + 6) this.costAdjustment = "SALE20";
    if (num < 10 + 8) this.costAdjustment = "SALE10";
    if (num < 18 + 3) this.costAdjustment = "OVER10";
    if (num < 21 + 5) this.costAdjustment = "OVER20";
    if (num < 26 + 7) this.costAdjustment = "OVER30";
    double adjustmentRate = Utils.costAdjustments[this.costAdjustment];
    int extraButtons = (totalCost * adjustmentRate).round(); // eller floor?

    int costDivide = rng.nextInt(80);
    this.time = totalCost * (costDivide / 100).round();
    this.cost = totalCost - this.time;
    print(this.costAdjustment + ": " + extraButtons.toString());
    this.cost += extraButtons;

    //costAdjustment

    //
  }

  bool _outOfBounds(Square square) {
    int min = 0;
    int max = 6;
    return square.x < min || square.x > max || square.y < min || square.y > max;
  }

  void rotatePiece() {
    //placera om coordinater för squares.
  }
  void flipPiece() {
    //positionera om squares
  }

  List<String> getVisual() {
    return _getVisual(this.squares);
  }

  List<String> _getVisual(List<Square> squares) {
    //retunera en visual presentation av squares
    List<String> s = [
      "[0][0][0][0][0][0][0][0][0]",
      "[0][0][0][0][0][0][0][0][0]",
      "[0][0][0][0][0][0][0][0][0]",
      "[0][0][0][0][0][0][0][0][0]",
      "[0][0][0][0][0][0][0][0][0]",
      "[0][0][0][0][0][0][0][0][0]",
      "[0][0][0][0][0][0][0][0][0]",
      "[0][0][0][0][0][0][0][0][0]",
      "[0][0][0][0][0][0][0][0][0]"
    ];

    for (int i = 0; i < squares.length; i++) {
      String row = s[squares[i].y];
      int startIndex = 1 + (squares[i].x * 3);
      final replaced = row.replaceFirst(RegExp('0'), 'X', startIndex);
      //row = replaced;
      s[squares[i].y] = replaced;
    }
    for (int i = 0; i < s.length; i++) {
      s[i] = s[i].replaceAll(RegExp('\\[0\\]'), "   ");
    }

    return s;
  }

  void render(List<String> s) {
    for (int i = 0; i < s.length; i++) {
      if (s[i].length > 0) {
        print(s[i]);
      }
    }
  }
}

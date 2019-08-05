import 'dart:math';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/player.dart';

class RuleEngine {
  static Square _west = new Square(-1, 0);
  static Square _east = new Square(1, 0);
  static Square _north = new Square(0, -1);
  static Square _south = new Square(0, 1);
  static final List directions = [_west, _east, _north, _south];

  static List<Piece> generatePieces() {
    List<Piece> pieces = [];
    for (int i = 0; i < 100; i++) {
      Piece p = new Piece(i);
      pieces.add(p);
    }

    return pieces;
    //p.squares = [new Square(0,0),new Square(1,0),new Square(2,0),new Square(2,1)];
    //sköt genereringen av size, suares osv här tack. för det är en del av logiken. eller nej förresten det är hårt kopplat till modellen
    // valideringen av det kan vi göra här för att se till så att vi får tillräckligt olika bitar
    // return p;
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

/* 

let table = $("table")[0];
let rows = $("tr");

function generatePiece(){
  let size = getSize();
  let buttons = getButtons(size);
  let squares = getSquares(size);
  let piece = {
    squares,
    size,
    time: 1,
    buttons,
    cost: 1,
  };
  return piece;
}

function getSize(){
  //skulle kunna ta in befintliga peices och avgöra chanserna lite baserat på det.
  //alltså om det är ett högt medel på befntliga så lutar vi mer åt att skapa en lägre och lika åt andra hållet
  let num = Math.random() * 100;
  if(num <5) return 2;
  if(num <5+8) return 3;
  if(num <13+9) return 4;
  if(num <22+11) return 5;
  if(num <33+12) return 6;
  if(num <45+13) return 7;
  if(num <58+12) return 8;
  if(num <70+11) return 9;
  if(num <81+9) return 10;
  if(num <90+6) return 11;
  return 12;  
}

let nrs = [];
for(let i = 0; i<10; i++){
  nrs.push(getSize());
}
//console.log("two:" + nrs.filter(x=> x===2).length);

//console.log(nrs);  
function validatePiece(piece){
  //om den har en allt för konstig form så är den ogiltig.
  //en regel är t.ex att den inte får skilja 4 mellan hösta och lägsta x och y
  //alltså har biten en max x på 4 och en min x på 0 och samtidgt en max y på 5 och min y på 1 så är den ogiltig
  //lite olika regler beroende på hur stor biten är.
  //det är just det här med hur många hål eller liknande som finns i biten som sätter svårighetsgraden
  //skapa en värdering av svårighetsgrad här. allt för svåra är ogiltiga, men svårighetsgraden ger bättre kostnad också
  //svårighetsgrad räknas ut av att ta just edge cases max och min av x och y.
  //samt totalt antal squares. Då kan man uppskatta hur många tomma rutor det finns.
  //kan även köra en funkton som komma om det finns ett hål i biten. för då är den rakt av ogiltig.
  
}

function getButtons(size){
  let max = size-1;
  let num = Math.random() * 100;
  if(num <30) return 0;
  if(num <30+20) return 1;
  if(num <50+20) return Math.min(max,2);
  if(num <70+15) return Math.min(max,3);
  if(num <85+11) return Math.min(max,4);
  return Math.min(max,5);
}


function scaleSquares(squares){
    console.log("asdfff");
  console.log(squares.length)

  let scaledSquares = [...squares];
  let minY = squares.reduce((a,b) => a.y < b.y ? a : b).y;
  CONSOLE.LOG(squares);

  while(minY > 0){
     scaledSquares = scaledSquares.map(s => {x: s.x, y: s.y-1});
     minY = scaledSquares.reduce((a,b) => a.y < b.y ? a : b).y;
  }
  return scaledSquares;
  //se till så att bitarna lägger sig så lång upp till vänster som möjligt.
  //alltså ta minus 1 på alla cordinater tills någon slår i kanten
  
}

function getSquares(size){
    let squares = [];

    let west = {x:-1, y:0};
    let east = {x:1, y:0};
    let north = {x:0, y:-1};
    let south = {x:0, y:1};
    let directions = [west, east, north, south];
    let startX = Math.floor(Math.random() * 7);
    let startY = Math.floor(Math.random() * 7);
    squares.push({x:startX, y:startY});
    while(squares.length < size){
      let latestSquare = squares[squares.length-1];
      let direction = directions[Math.floor(Math.random() * 4)];
      let newSquare = {
        x: latestSquare.x + direction.x,
        y: latestSquare.y + direction.y
      };
      if(outOfBounds(newSquare)){
        continue;
      }
      let existingSquare = squares.findIndex(s=> s.x===newSquare.x && s.y===newSquare.y);
      if(existingSquare > -1){
          squares.splice(existingSquare, 1);
      }
      squares.push(newSquare);
      
    }
  return scaleSquares(squares);
  
}


function outOfBounds(square){
  let min = 0;
  let max = 6;
  return square.x < min || square.x > max || square.y < min || square.max > max;
}

let piece = generatePiece();
piece.squares.forEach((cord) => {
  let row = rows[cord.y];
  let td = $(row).find("td")[cord.x];
  $(td).css('background-color', 'gray');
}) */

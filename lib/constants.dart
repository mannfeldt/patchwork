import 'package:flutter/material.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/models/piece.dart';

const double draggablePatchSize = 30.0;
const double patchUnitSize = 20.0;
const double patchUnitSizeWithPadding = patchUnitSize + 1.0;
const double boardTilePadding = 1.0;
typedef PatchPlacedCallback = void Function(Piece piece);

enum GameMode { DEFAULT, SURVIVAL }
const Map<GameMode, String> gameModeName = {
  GameMode.DEFAULT: "Default",
  GameMode.SURVIVAL: "Survival"
};

const double timeBoardTileHeight = 30.0;
const double timeBoardTileWidth = 90.0;
const double boardInset = 5.0;
const int maxPieceSize = 10;
const int maxPieceLength = 6;
final Square _west = new Square.simple(-1, 0);
final Square _east = new Square.simple(1, 0);
final Square _north = new Square.simple(0, -1);
final Square _south = new Square.simple(0, 1);
//lite statas från default pieces: 55% av cost är i buttons 45% i time. så buttons ska vara lite större chans att få mer cost än time
//avarage buttons är strax över 1
const int minimumPlayers = 2;
const int maximumPlayers = 10;
final List<Square> directions = [_west, _east, _north, _south];
final List<Color> pieceColors = [
  Colors.indigo,
  Colors.lightGreen,
  Colors.amber,
  Colors.deepOrange
];
final List<Color> playerColors = Colors.primaries;
// final List<Color> playerColors = [
//   Colors.blue.shade700,
//   Colors.red.shade700,
//   Colors.orange.shade700,
//   Colors.green.shade700,
//   Colors.yellow.shade700,
//   Colors.purple.shade700,
//   Colors.teal.shade700,
//   Colors.pink.shade700,
//   Colors.black87,
//   Colors.blueAccent.shade700,
//   Colors.brown.shade700,
//   Colors.cyan.shade700,
//   Colors.cyanAccent.shade700,
//   Colors.deepOrange.shade700,
//   Colors.deepOrangeAccent.shade700,
//   Colors.deepPurple.shade700,
//   Colors.deepPurpleAccent.shade700,
//   Colors.greenAccent.shade700,
//   Colors.indigo.shade700,
//   Colors.indigoAccent.shade700,
//   Colors.blueGrey.shade700,
// ];
final Map<String, double> costAdjustments = {
  "SALE30": -0.3,
  "SALE20": -0.2,
  "SALE10": -0.1,
  "OVER10": 0.1,
  "OVER20": 0.2,
  "OVER30": 0.3,
  "NONE": 0.0
};

final List<List<String>> spicyPieces = [
  [
    "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    "[X][X][ ][X][X][ ][ ][ ][ ]",
    "[ ][X][X][X][ ][ ][ ][ ][ ]",
    "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
  ],
];

final List defaultPieces = [
  {
    "visual": [
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][X][ ][ ][ ][ ][ ][ ]",
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 1,
    "cost": 0,
    "time": 3
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][X][X][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][X][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 0,
    "cost": 1,
    "time": 2
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][X][X][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 3,
    "cost": 10,
    "time": 4
  },
  {
    "visual": [
      "[X][ ][X][ ][ ][ ][ ][ ][ ]",
      "[X][X][X][ ][ ][ ][ ][ ][ ]",
      "[X][ ][X][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 0,
    "cost": 2,
    "time": 3
  },
  {
    "visual": [
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][X][ ][ ][ ][ ][ ][ ]",
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 2,
    "cost": 5,
    "time": 4
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 1,
    "cost": 3,
    "time": 3
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][X][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 2,
    "cost": 5,
    "time": 5
  },
  {
    "visual": [
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][X][X][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 3,
    "cost": 8,
    "time": 6
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 1,
    "cost": 3,
    "time": 2
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 1,
    "cost": 2,
    "time": 3
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][X][X][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 2,
    "cost": 7,
    "time": 2
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 1,
    "cost": 3,
    "time": 4
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 0,
    "cost": 4,
    "time": 2
  },
  {
    "visual": [
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 1,
    "cost": 1,
    "time": 5
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 2,
    "cost": 10,
    "time": 3
  },
  {
    "visual": [
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][X][ ][ ][ ][ ][ ][ ]",
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 1,
    "cost": 1,
    "time": 4
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 0,
    "cost": 2,
    "time": 1
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 0,
    "cost": 2,
    "time": 2
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 1,
    "cost": 7,
    "time": 1
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 3,
    "cost": 10,
    "time": 5
  },
  {
    "visual": [
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][X][ ][ ][ ][ ][ ][ ]",
      "[X][X][X][ ][ ][ ][ ][ ][ ]",
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 1,
    "cost": 5,
    "time": 3
  },
  {
    "visual": [
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 2,
    "cost": 6,
    "time": 5
  },
  {
    "visual": [
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 0,
    "cost": 1,
    "time": 2
  },
  {
    "visual": [
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][X][X][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 2,
    "cost": 3,
    "time": 6
  },
  {
    "visual": [
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][X][X][ ][ ][ ][ ][ ][ ]",
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 0,
    "cost": 2,
    "time": 1
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 2,
    "cost": 4,
    "time": 6
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 0,
    "cost": 3,
    "time": 1
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 2,
    "cost": 7,
    "time": 4
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 3,
    "cost": 7,
    "time": 6
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 0,
    "cost": 1,
    "time": 3
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 0,
    "cost": 2,
    "time": 2
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 0,
    "cost": 2,
    "time": 2
  },
  {
    "visual": [
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[X][X][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
      "[ ][ ][ ][ ][ ][ ][ ][ ][ ]",
    ],
    "buttons": 1,
    "cost": 4,
    "time": 2
  },
];

// gör detta till en lista av pieces. eller iaf så att de innehåller info om buttons och cost.
//om jag skapar en mix mellan default och spicy/random så ska jag bara läsa shapes så att alla använder samma algoritm för cost
//behöver alltså en ny konstruktor i pieces(id, shape, time, cost, buttons)
//när jag blandar så tar jag samma lista fast plockar ut shape bara och skapar om genom fromvisual

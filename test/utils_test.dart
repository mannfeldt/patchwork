import 'package:flutter_test/flutter_test.dart';
import 'package:patchwork/models/board.dart';
import 'package:patchwork/models/lootBox.dart';
import 'package:patchwork/models/lootPrice.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/utilities/utils.dart';

void main() {
  group('getLootbox', () {
    test('loot box should contain correct amount of lootPrices', () {
      LootBox lootBox = Utils.getLootBox(1);
      expect(lootBox.prices.length, lootBoxPricesNr);
    });
    test('valueFactor should be set', () {
      LootBox lootBox = Utils.getLootBox(2);
      expect(lootBox.valueFactor, 2);
    });
    test('winning loot price should be at index 5-10 from the end of the list',
        () {
      LootBox lootBox = Utils.getLootBox(1);
      LootPrice win = lootBox.win;
      int winIndex = lootBox.prices.indexWhere((p) => p.id == win.id);
      int indexFromEnd = lootBox.prices.length - winIndex;
      Matcher lowerEnd = greaterThanOrEqualTo(5);
      Matcher higherEnd = lessThanOrEqualTo(10);
      expect(indexFromEnd, lowerEnd);
      expect(indexFromEnd, higherEnd);
    });
  });
  group('isOutOfBoardBounds', () {
    test('square is inside bounds', () {
      Board board = new Board(null);
      board.cols = 2;
      board.rows = 2;
      bool outOfBounds = Utils.isOutOfBoardBounds([
        new Square.simple(0, 0),
        new Square.simple(0, 1),
        new Square.simple(1, 0),
        new Square.simple(1, 1)
      ], board);
      expect(outOfBounds, false);
    });
    test('square is out of bounds left side', () {
      Board board = new Board(null);
      board.cols = 2;
      board.rows = 2;
      bool outOfBounds = Utils.isOutOfBoardBounds(
          [new Square.simple(-1, 1), new Square.simple(0, 1)], board);
      expect(outOfBounds, true);
    });
    test('square is out of bounds right side', () {
      Board board = new Board(null);
      board.cols = 2;
      board.rows = 2;
      bool outOfBounds = Utils.isOutOfBoardBounds(
          [new Square.simple(1, 1), new Square.simple(2, 1)], board);
      expect(outOfBounds, true);
    });
    test('square is out of bounds top side', () {
      Board board = new Board(null);
      board.cols = 2;
      board.rows = 2;
      bool outOfBounds = Utils.isOutOfBoardBounds(
          [new Square.simple(1, -1), new Square.simple(1, 0)], board);
      expect(outOfBounds, true);
    });
    test('square is out of bounds bottom side', () {
      Board board = new Board(null);
      board.cols = 2;
      board.rows = 2;
      bool outOfBounds = Utils.isOutOfBoardBounds(
          [new Square.simple(1, 1), new Square.simple(1, 2)], board);
      expect(outOfBounds, true);
    });
  });
  group('emptyBoardSpaces', () {
    test('no empty board spaces', () {
      Board board = new Board(null);
      board.cols = 2;
      board.rows = 2;
      board.squares = [null, null, null, null];
      int emptySpaces = Utils.emptyBoardSpaces(board);
      expect(emptySpaces, 0);
    });
    test('some empty board spaces', () {
      Board board = new Board(null);
      board.cols = 2;
      board.rows = 2;
      board.squares = [null, null];
      int emptySpaces = Utils.emptyBoardSpaces(board);
      expect(emptySpaces, 2);
    });
    test('only empty board spaces', () {
      Board board = new Board(null);
      board.cols = 2;
      board.rows = 2;
      board.squares = [];
      int emptySpaces = Utils.emptyBoardSpaces(board);
      expect(emptySpaces, 4);
    });
  });

  group('hasRoom', () {
    test('board has room', () {
      Board board = new Board(null);
      board.squares = [new Square.simple(0, 0), new Square.simple(1, 0)];
      bool room = Utils.hasRoom(
          [new Square.simple(0, 1), new Square.simple(1, 1)], board);
      expect(room, true);
    });
    test('board has no room', () {
      Board board = new Board(null);
      board.squares = [new Square.simple(0, 0), new Square.simple(1, 0)];
      bool room = Utils.hasRoom(
          [new Square.simple(1, 0), new Square.simple(1, 1)], board);
      expect(room, false);
    });
  });
  group('validateScissorsPlacement', () {
    test('invalid placement of scissors', () {
      Board board = new Board(null);
      board.squares = [new Square.simple(0, 0), new Square.simple(1, 0)];
      bool valid =
          Utils.validateScissorsPlacement(new Square.simple(1, 1), board);
      expect(valid, false);
    });
    test('valid placement of scissors', () {
      Board board = new Board(null);
      board.squares = [new Square.simple(0, 0), new Square.simple(1, 0)];
      bool valid =
          Utils.validateScissorsPlacement(new Square.simple(1, 0), board);
      expect(valid, true);
    });
  });
  //testa lite fler metoder.
  //testa:
  // board.dart, test att addpiece lägger till biten i listan och även ökar board.buttons.
  //
  //piecegenerator.fromVisual(),
  // setup.dart (widget testing)
  //pieceslectorn. testa så att den visar rätt antal varje gång. även efter placering av bit.

  //(widget testing / integration testing)
  //testa en hel action? att placera en bit på board så ta betalt av playern i position och buttons, mindska playerns emptyspaces på board, 
  //testa pass, både med en och flera motstänadere, testa så att det blir rätt spelares tur att spela.
  //vad mer är vanliga testfall?
  //går man förbi en button/scissor/piece så ska det hända något (få buttons/button animation visas, singlepiece visas)

}

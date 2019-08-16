import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/square.dart';
import 'dart:ui' as ui;

final String assetName2 = 'assets/J.png';

final String assetName = 'assets/snow.svg';

const cornerRadius = Radius.circular(0.0);

class PatchShaper extends CustomPainter {
  final Piece piece;
  final double unitSize;
  final double padding;
  final bool dragged;
  final ui.Image img;

  const PatchShaper(
      {@required this.piece,
      this.unitSize = 16.0,
      this.dragged = false,
      this.img,
      this.padding = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
//paintImage(canvas: canvas, rect: new Rect.fromCircle(), image: img);

//draggable rects kan vara större. så ha två olika varianter. styrs i draggable widgeten..
//se till att rotera så att de inte är längst på brädden så det får plats
//räkna på vad som då blir maximal bredd på en piece. kan

//hur ska jag hanera flip och rotation? gör man det innan man drar i den? ska man kunna lägga ner biten var som helst och roter aden?
//jag tror det är best och enklast att kunna rotera den på plats innan man drar. då blir så varje dragable eller patch har knappar på sig som roterar eller speglar piecen

//behöver responsiv design. kolla in layoutbuilder eller mediaqueries     var screenSize = MediaQuery.of(context).size;
//varje patch ska ha två knappar. rotera och flippa nere till vänster och höger. skriv också ut cost, time. rea, får snygga till senare.
//behöver också skriva märka de squares som har en knapp. lägg ut knappar ovanpå dem

// om jag foracar portfrait mode. och lägger board.hegith == screen.width så att den är perfekt. lite padding såklart.
//sen den övriga utrymmet upp till blir ju då screen.hegiht-screen.width den storleken kan jag använda till piecelistan?

//jag måste sizea upp precis hur stor en square blir på boardet. patchUnitSize måste vara dymaiskt, lika så patchDraggableUnitSize?
    double squareSize = unitSize;
    print("PAINTING------------------");
    var buttonPaint = Paint()..color = Colors.lightBlue;

    var patchPaint;
    if (dragged) {
      patchPaint = Paint()..color = piece.color.withOpacity(0.4);
      squareSize = (unitSize + boardTilePadding) * 2;
    } else {
      patchPaint = Paint()..color = piece.color;
    }
    //Image img = Image.asset(assetName);
    //AssetImage img2 = new AssetImage(assetName);
    if (img != null) {
      //img.height=squareSize.round();
      //img.width=squareSize.round();
      canvas.drawImage(img, new Offset(0.0, 0.0), new Paint());
      //jag skulle kunna lägga till image som ett attribut i constans på alla default pieces.
      //och de
    }

    for (int i = 0; i < piece.shape.length; i++) {
      Square square = piece.shape[i];
      var tile = _createpatchUnit(
          square.x * squareSize, square.y * squareSize, squareSize, squareSize);
      canvas.drawRRect(tile, patchPaint);
      if (square.hasButton && !dragged) {
        canvas.drawCircle(
            new Offset(square.x * squareSize + squareSize / 2,
                square.y * squareSize + squareSize / 2),
            6,
            buttonPaint);
      }
    }
  }

  @override
  bool shouldRepaint(PatchShaper patch) {
    return true;
  }

  RRect _createpatchUnit(double left, double top, double width, double height) {
    return RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, width, height), cornerRadius);
  }
}

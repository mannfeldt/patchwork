import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:patchwork/gamestate.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/patchShaper.dart';
import 'package:patchwork/patchwork_icons_icons.dart';
import 'dart:ui' as ui;

import 'package:provider/provider.dart';

typedef PatchDroppedCallback = void Function();
typedef PatchDragStartCallback = void Function(Piece piece);

class Patch extends StatefulWidget {
  final double patchSize;
  final Piece piece;
  final ui.Image img;
  final PatchDroppedCallback patchDroppedCallback;
  final PatchDragStartCallback patchDragStartCallback;
  final bool draggable;

  Patch(this.piece,
      {this.patchDroppedCallback,
      this.patchDragStartCallback,
      this.draggable = false,
      this.img,
      this.patchSize = patchUnitSize});

  @override
  _PatchState createState() => _PatchState();
}

class _PatchState extends State<Patch> {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    if (widget.draggable) {
      return Draggable<Piece>(
        childWhenDragging: Container(
          height: _getPatchContainerHeight(widget.piece) / 2,
        ),
        child: _createPatch(widget.piece, widget.patchSize),
        feedback: _createDraggedPatch(widget.piece, widget.patchSize),
        data: widget.piece,
        onDragEnd: _handleDragEnded,
        ignoringFeedbackSemantics: true,
        maxSimultaneousDrags: 1,
        onDragCompleted: () {},
        onDragStarted: _handleDragStart,
        dragAnchor: DragAnchor.pointer,
        feedbackOffset: Offset(widget.patchSize / 2, widget.patchSize / 2),
      );
    } else {
      return _createPatch(widget.piece, widget.patchSize);
    }
  }

  void _handleDragEnded(DraggableDetails draggableDetails) {
    if (widget.patchDroppedCallback != null) {
      widget.patchDroppedCallback();
    }
  }

  void _handleDragStart() {
    if (widget.patchDragStartCallback != null) {
      widget.patchDragStartCallback(widget.piece);
    }
  }

  Widget _createFixedPatch(Piece piece, double patchSize) {
    return Container(
        margin: EdgeInsets.all(1.0),
        width: _getPatchContainerWidth(piece) / 2,
        height: _getPatchContainerHeight(piece) / 2,
        child: new RepaintBoundary(
            child: CustomPaint(
          painter: PatchShaper(
              piece: piece,
              unitSize: patchSize / 2,
              dragged: false,
              img: widget.img),
        )));
  }

  Widget _createPatch(Piece piece, double patchSize) {
    //den här ska innehålla knappar för rotera och flippa
    int pHeight = piece.shape.reduce((a, b) => a.y > b.y ? a : b).y + 1;
    int pWidth = piece.shape.reduce((a, b) => a.x > b.x ? a : b).x + 1;
    double containerHeight = patchSize * (pHeight / 2);
    double containerWidth = pWidth * (patchSize / 2);
    return Container(
        margin: EdgeInsets.all(1.0),
        width: containerWidth,
        height: containerHeight,
        child: GridView.count(
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          physics: ScrollPhysics(),

          crossAxisCount: pWidth,
          // Generate 100 widgets that display their index in the List.
          children: List.generate(pWidth * pHeight, (index) {
            int x = index % pWidth;
            int y = (index / pWidth).floor();
            Square square = piece.shape
                .firstWhere((s) => s.x == x && s.y == y, orElse: () => null);
            Widget patchImage;
            if (square == null) {
              patchImage = Container(
                width: patchSize / 2,
                height: patchSize / 2,
              );
            } else if (square != null && square.hasButton) {
              patchImage = Stack(
                children: <Widget>[
                  Image.asset("assets/" + square.imgSrc, width: patchSize / 2),
                  Icon(
                    PatchworkIcons.button_icon,
                    color: Colors.blue.shade800.withOpacity(0.8),
                    size: patchSize / 2,
                  )
                ],
              );
            } else {
              patchImage =
                  Image.asset("assets/" + square.imgSrc, width: patchSize / 2);
            }
            return Center(child: patchImage);
          }),
        ));
  }

  Widget _createDraggedPatch(Piece piece, double patchSize) {
    //denna ska vara något större kanske?iaf matcha storleken av boardet. och lite opacity
    int pHeight = piece.shape.reduce((a, b) => a.y > b.y ? a : b).y + 1;
    int pWidth = piece.shape.reduce((a, b) => a.x > b.x ? a : b).x + 1;
    double containerHeight = patchSize * pHeight;
    double containerWidth = pWidth * patchSize;
    final gameState = Provider.of<GameState>(context);

    return Container(
        margin: EdgeInsets.all(1.0),
        width: containerWidth,
        height: containerHeight,
        alignment: Alignment.topLeft,
        child: Column(
          children: <Widget>[
            Expanded(
                child: GridView.count(
              crossAxisCount: pWidth,
              padding: EdgeInsets.all(0),
              children: List.generate(pWidth * pHeight, (index) {
                int x = index % pWidth;
                int y = (index / pWidth).floor();
                Square square = piece.shape.firstWhere(
                    (s) => s.x == x && s.y == y,
                    orElse: () => null);
                Widget patchImage;
                if (square == null) {
                  patchImage = Container(
                    width: patchSize,
                    height: patchSize,
                  );
                } else if (square != null && square.hasButton) {
                  patchImage = Stack(
                    children: <Widget>[
                      Image.asset("assets/" + square.imgSrc, width: patchSize),
                      Icon(
                        PatchworkIcons.button_icon,
                        color: Colors.blue.shade800.withOpacity(0.8),
                        size: patchSize,
                      )
                    ],
                  );
                } else {
                  patchImage =
                      Image.asset("assets/" + square.imgSrc, width: patchSize);
                }
                return Center(child: patchImage);
              }),
            ))
          ],
        ));
  }

  double _getPatchContainerWidth(Piece piece) {
    //hurfungerar dessa. tetsa stora bitar!!
    double width = widget.patchSize;
    int maxWidth = piece.shape.reduce((a, b) => a.x > b.x ? a : b).x + 1;
    return width * maxWidth;
  }

  double _getPatchContainerHeight(Piece piece) {
    double height = widget.patchSize;
    int maxHeight = piece.shape.reduce((a, b) => a.y > b.y ? a : b).y + 1;
    return height * maxHeight;
  }
}

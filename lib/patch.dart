import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:patchwork/gamestate.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/patchShaper.dart';
import 'dart:ui' as ui;

import 'package:provider/provider.dart';

typedef PatchDroppedCallback = void Function(Piece piece, Offset patchPosition);

class Patch extends StatefulWidget {
  final double patchSize;
  final Piece piece;
  final ui.Image img;
  final PatchDroppedCallback patchDroppedCallback;
  final bool draggable;

  Patch(this.piece,
      {this.patchDroppedCallback,
      this.draggable = false,
      this.img,
      this.patchSize = patchUnitSize});

  @override
  _PatchState createState() => _PatchState();
}

class _PatchState extends State<Patch> {
  @override
  Widget build(BuildContext context) {
    if (widget.draggable) {
      return Draggable<Piece>(
        childWhenDragging: Container(
          height: _getPatchContainerHeight(widget.piece) / 2,
        ),
        child: _createPatch(widget.piece, widget.patchSize),
        feedback: _createDraggedPatch(widget.piece, patchUnitSize),
        data: widget.piece,
        onDragEnd: _handleDragEnded,
        onDraggableCanceled: (velocity, offset) {},
        onDragCompleted: () {},
        onDragStarted: () {},
        dragAnchor: DragAnchor.pointer,
        feedbackOffset: Offset(widget.patchSize / 2, widget.patchSize / 2),
      );
    } else {
      return _createFixedPatch(widget.piece, widget.patchSize);
    }
  }

  void _handleDragEnded(DraggableDetails draggableDetails) {
    if (widget.patchDroppedCallback != null) {
      widget.patchDroppedCallback(widget.piece, draggableDetails.offset);
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

  Widget _createDraggedPatch(Piece piece, double patchSize) {
    //denna ska vara något större kanske?iaf matcha storleken av boardet. och lite opacity
    return Container(
        margin: EdgeInsets.all(1.0),
        width: _getPatchContainerWidth(piece),
        height: _getPatchContainerHeight(piece),
        child: new RepaintBoundary(
            child: CustomPaint(
          painter: PatchShaper(
              piece: piece,
              unitSize: patchSize + boardTilePadding,
              dragged: true,
              img: widget.img),
        )));
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

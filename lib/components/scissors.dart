import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:patchwork/models/piece.dart';

typedef PatchDroppedCallback = void Function();
typedef PatchDragStartCallback = void Function(Piece piece);

class Scissors extends StatefulWidget {
  final PatchDroppedCallback patchDroppedCallback;
  final PatchDragStartCallback patchDragStartCallback;
  final double size;
  final Piece scissors;

  Scissors(
      {this.scissors,
      this.patchDroppedCallback,
      this.patchDragStartCallback,
      this.size});

  @override
  _ScissorsState createState() => _ScissorsState();
}

class _ScissorsState extends State<Scissors> {
  @override
  Widget build(BuildContext context) {
    return Draggable<Piece>(
      childWhenDragging: Container(height: widget.size * 2),
      child: Container(
          margin: EdgeInsets.all(1.0),
          width: widget.size * 2,
          height: widget.size * 2,
          child: Center(child: Icon(Icons.content_cut, size: widget.size))),
      feedback: Container(
          margin: EdgeInsets.all(1.0),
          width: widget.size * 2,
          height: widget.size * 2,
          child: Center(child: Icon(Icons.content_cut, size: widget.size))),
      data: widget.scissors,
      ignoringFeedbackSemantics: true,
      maxSimultaneousDrags: 1,
      onDragCompleted: () {},
      onDraggableCanceled: _handleDragEnded,
      onDragStarted: _handleDragStart,
      dragAnchor: DragAnchor.child,
    );
  }

  void _handleDragEnded(Velocity v, Offset o) {
    if (widget.patchDroppedCallback != null) {
      widget.patchDroppedCallback();
    }
  }

  void _handleDragStart() {
    if (widget.patchDragStartCallback != null) {
      widget.patchDragStartCallback(widget.scissors);
    }
  }
}

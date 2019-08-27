import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/utilities/patchwork_icons_icons.dart';

typedef PatchDroppedCallback = void Function();
typedef PatchDragStartCallback = void Function(Piece piece);

class Patch extends StatefulWidget {
  final double patchSize;
  final Piece piece;
  final PatchDroppedCallback patchDroppedCallback;
  final PatchDragStartCallback patchDragStartCallback;
  final flipCallback;
  final rotateCallback;
  final bool draggable;
  final bool single;

  Patch(this.piece,
      {this.patchDroppedCallback,
      this.patchDragStartCallback,
      this.draggable = false,
      this.single,
      this.flipCallback,
      this.rotateCallback,
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
        child: _createPatch(widget.piece, widget.patchSize, widget.single),
        feedback: _createDraggedPatch(widget.piece, widget.patchSize),
        data: widget.piece,
        ignoringFeedbackSemantics: true,
        maxSimultaneousDrags: 1,
        onDragCompleted: () {},
        onDraggableCanceled: _handleDragEnded,
        onDragStarted: _handleDragStart,
        dragAnchor: DragAnchor.pointer,
        feedbackOffset: Offset(widget.patchSize / 2, widget.patchSize / 2),
      );
    } else {
      return _createPatch(widget.piece, widget.patchSize, widget.single);
    }
  }

  void _handleDragEnded(Velocity v, Offset o) {
    if (widget.patchDroppedCallback != null) {
      widget.patchDroppedCallback();
    }
  }

  void _handleDragStart() {
    if (widget.patchDragStartCallback != null) {
      widget.patchDragStartCallback(widget.piece);
    }
  }

  Widget _createPatch(Piece piece, double patchSize, bool single) {
    //den här ska innehålla knappar för rotera och flippa
    int pHeight = piece.shape.reduce((a, b) => a.y > b.y ? a : b).y + 1;
    int pWidth = piece.shape.reduce((a, b) => a.x > b.x ? a : b).x + 1;
    double containerHeight = patchSize * (pHeight / 2);
    double containerWidth = pWidth * (patchSize / 2);

    if (single != null && single) {
      return Container(
          margin: EdgeInsets.all(1.0),
          width: patchSize,
          height: patchSize,
          child: Center(
              child: Container(
                  width: patchSize,
                  height: patchSize,
                  child: FittedBox(
                    child: Image.asset(
                      "assets/" + piece.shape[0].imgSrc,
                    ),
                    fit: BoxFit.fill,
                  ))));
    }

    return Card(
      elevation: widget.draggable ? 3 : 0,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Center(
              child: Container(
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
                      Square square = piece.shape.firstWhere(
                          (s) => s.x == x && s.y == y,
                          orElse: () => null);
                      Widget patchImage;
                      if (square == null) {
                        patchImage = Container(
                          width: patchSize / 2,
                          height: patchSize / 2,
                        );
                      } else if (square != null && square.hasButton) {
                        patchImage = Stack(
                          children: <Widget>[
                            Container(
                                width: patchSize / 2,
                                height: patchSize / 2,
                                child: FittedBox(
                                  child: Image.asset(
                                    "assets/" + square.imgSrc,
                                  ),
                                  fit: BoxFit.fill,
                                )),
                            Icon(
                              PatchworkIcons.button_icon,
                              color: buttonColor,
                              size: patchSize / 2,
                            )
                          ],
                        );
                      } else {
                        patchImage = Container(
                            width: patchSize / 2,
                            height: patchSize / 2,
                            child: FittedBox(
                              child: Image.asset(
                                "assets/" + square.imgSrc,
                              ),
                              fit: BoxFit.fill,
                            ));
                      }
                      return Center(child: patchImage);
                    }),
                  ))),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    iconSize: patchSize / 2,
                    icon: Icon(
                      Icons.rotate_left,
                    ),
                    onPressed: () {
                      //detta kan göras i util? behöver ote notifiera alla. retunrera nya roterade och stt lika med darggpicee eller bara rotera den i metoden?

                      widget.rotateCallback(piece);
                    },
                  ),
                  IconButton(
                    iconSize: patchSize / 2,
                    icon: Icon(Icons.flip),
                    onPressed: () {
                      //detta kan göras i util? behöver ote notifiera alla. retunrera nya roterade och stt lika med darggpicee eller bara rotera den i metoden?
                      widget.flipCallback(piece);
                    },
                  )
                ],
              ))
        ],
      ),
    );

    ;
  }

  Widget _createDraggedPatch(Piece piece, double patchSize) {
    //denna ska vara något större kanske?iaf matcha storleken av boardet. och lite opacity
    int pHeight = piece.shape.reduce((a, b) => a.y > b.y ? a : b).y + 1;
    int pWidth = piece.shape.reduce((a, b) => a.x > b.x ? a : b).x + 1;
    double containerHeight = patchSize * pHeight;
    double containerWidth = pWidth * patchSize;

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
                      Container(
                          width: patchSize,
                          height: patchSize,
                          child: FittedBox(
                            child: Image.asset(
                              "assets/" + square.imgSrc,
                            ),
                            fit: BoxFit.fill,
                          )),
                      Icon(
                        PatchworkIcons.button_icon,
                        color: buttonColor,
                        size: patchSize,
                      )
                    ],
                  );
                } else {
                  patchImage = Container(
                      width: patchSize,
                      height: patchSize,
                      child: FittedBox(
                        child: Image.asset(
                          "assets/" + square.imgSrc,
                        ),
                        fit: BoxFit.fill,
                      ));
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

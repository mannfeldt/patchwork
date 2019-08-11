import 'package:patchwork/models/piece.dart';
import 'package:patchwork/models/square.dart';

class Utils {
  static List<Square> cropPiece(List<Square> shape) {
    int minY = shape.reduce((a, b) => a.y < b.y ? a : b).y;
    int minX = shape.reduce((a, b) => a.x < b.x ? a : b).x;

    List<Square> croppedShape = [];
    croppedShape.addAll(shape);

    while (minY > 0) {
      croppedShape.forEach((s) => s.y -= 1);
      minY = croppedShape.reduce((a, b) => a.y < b.y ? a : b).y;
    }
    while (minY < 0) {
      croppedShape.forEach((s) => s.y += 1);
      minY = croppedShape.reduce((a, b) => a.y < b.y ? a : b).y;
    }
    while (minX < 0) {
      croppedShape.forEach((s) => s.x += 1);
      minX = croppedShape.reduce((a, b) => a.x < b.x ? a : b).x;
    }
    while (minX > 0) {
      croppedShape.forEach((s) => s.x -= 1);
      minX = croppedShape.reduce((a, b) => a.x < b.x ? a : b).x;
    }
    return croppedShape;
  }

  static Piece rotatePiece(Piece piece) {
    List<Square> shape = piece.shape;
    List<Square> newShape = [];
    int maxX = shape.reduce((a, b) => a.x > b.x ? a : b).x;
    int centerX = (maxX / 2).round();
    int maxY = shape.reduce((a, b) => a.y > b.y ? a : b).y;
    int centerY = (maxY / 2).round();
    Square centerPoint = new Square(centerX, centerY, false);

    List<int> rotationDirectionX = [0, -1];
    List<int> rotationDirectionY = [1, 0];

    for (int i = 0; i < shape.length; i++) {
      Square before = shape[i];
      Square vr =
          new Square(before.x - centerPoint.x, before.y - centerPoint.y, false);
      int relativeNewPositionX =
          (rotationDirectionX[0] * vr.x) + (rotationDirectionX[1] * vr.y);
      int relativeNewPositionY =
          (rotationDirectionY[0] * vr.x) + (rotationDirectionY[1] * vr.y);
      Square relativeNewSquare =
          new Square(relativeNewPositionX, relativeNewPositionY, false);

      before.x = centerPoint.x + relativeNewSquare.x;
      before.y = centerPoint.y + relativeNewSquare.y;
      newShape.add(before);
    }
    piece.shape = cropPiece(shape);
    return piece;
    //positionera om squares
  }

  static Piece flipPiece(Piece piece) {
    List<Square> shape = piece.shape;
    List<Square> newShape = [];
    int maxX = shape.reduce((a, b) => a.x > b.x ? a : b).x;
    int centerX = (maxX / 2).round();
    int maxY = shape.reduce((a, b) => a.y > b.y ? a : b).y;
    int centerY = (maxY / 2).round();
    Square centerPoint = new Square(centerX, centerY, false);

    List<int> rotationDirectionX = [0, -1];
    List<int> rotationDirectionY = [1, 0];

    for (int i = 0; i < shape.length; i++) {
      Square before = shape[i];
      Square vr =
          new Square(before.x - centerPoint.x, before.y - centerPoint.y, false);
      int relativeNewPositionX =
          (rotationDirectionX[0] * vr.x) + (rotationDirectionX[1] * vr.x);
      int relativeNewPositionY =
          (rotationDirectionY[0] * vr.y) + (rotationDirectionY[1] * vr.y);
      Square relativeNewSquare =
          new Square(relativeNewPositionX, relativeNewPositionY, false);

      before.x = centerPoint.x + relativeNewSquare.x;
      before.y = centerPoint.y + relativeNewSquare.y;
      newShape.add(before);
    }
    piece.shape = cropPiece(shape);
    return piece;
    //positionera om squares
  }
}

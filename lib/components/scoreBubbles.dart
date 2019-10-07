import 'package:flutter/material.dart';
import 'package:patchwork/utilities/constants.dart';

class ScoreBubbles extends StatelessWidget {
  final int plus;
  final int minus;
  final int extra;
  final int total;

  ScoreBubbles({this.plus, this.minus, this.extra, this.total});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          backgroundColor: buttonColor,
          child: Text(plus.toString(), style: TextStyle(color: Colors.white)),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: CircleAvatar(
            backgroundColor: Colors.red,
            child: Text(
              minus.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Visibility(
          visible: extra != 0,
          child: CircleAvatar(
            backgroundColor: Colors.green,
            child: Text(extra.toString(),
                style: TextStyle(color: Colors.white)),
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Text(total.toString(),
              style: TextStyle(color: Colors.black87)),
        )
      ],
    );
  }
}

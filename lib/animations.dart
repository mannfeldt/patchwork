import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/models/lootBox.dart';
import 'package:patchwork/models/lootPrice.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/patchwork_icons_icons.dart';

class ButtonAnimation extends StatefulWidget {
  final Player player;
  final double tileSize;
  ButtonAnimation(this.player, this.tileSize);

  @override
  _ButtonAnimationState createState() => _ButtonAnimationState();
}

class _ButtonAnimationState extends State<ButtonAnimation>
    with TickerProviderStateMixin {
  //AnimationController _ac;
  int buttonsnr;
  bool showIcon;

  @override
  void initState() {
    buttonsnr = widget.player.buttons;
    showIcon = false;
    super.initState();
    //_ac = AnimationController(vsync: this, duration: Duration(seconds: 3));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void animationCallback() {
    if (widget.player.buttons + widget.player.board.buttons == buttonsnr) {
      Navigator.pop(context);
    } else {
      print("callback added");
      setState(() {
        buttonsnr += 1;
        showIcon = true;
      });
    }
    //TODO 1

    //skippa recieve button vid goalline? eller hantera dubbla dialoger bättre. gäller också sevenBySeven
    //och kommande med lootboxes. köa dialogerna?
  }

  @override
  Widget build(BuildContext context) {
    //_ac.forward().then((x) => Navigator.pop(context));

    List<Square> buttonSquares =
        widget.player.board.squares.where((s) => s.hasButton).toList();
    List<Widget> children = [];
    children.add(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              widget.player.isAi ? Icons.android : Icons.person,
              color: widget.player.color,
            ),
            Text(widget.player.name),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("\$" + buttonsnr.toString()),
            Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: showIcon,
              child: Icon(
                PatchworkIcons.button_icon,
                color: buttonColor,
                size: widget.tileSize,
              ),
            )
          ],
        ),
      ],
    ));
    int longestDurationMs = 0;
    for (int i = 0; i < buttonSquares.length; i++) {
      Square s = buttonSquares[i];

      double breakPointY = MediaQuery.of(context).size.height / 2;
      double breakY = (breakPointY / widget.tileSize);

      double startLeft = (s.x - 4) * (widget.tileSize);
      double startTop = (s.y - breakY) * (widget.tileSize);

      if (startTop < 0) {
        startTop += widget.tileSize / 2;
        startTop += (10 - s.y) * 1;
      }
      if (s.x == 7) {
        startLeft -= widget.tileSize / 2;
      } else if (s.x == 8) {
        startLeft -= widget.tileSize;
      }
      if (startLeft > 0) {
        startLeft += (s.x - 4) * 1;
      }
      double endTop = widget.tileSize / 1.5;
      double endLeft = widget.tileSize / 1.5;

      Random rng = new Random();
      int rngMs = rng.nextInt(200);
      int closestXposToDialog = 4;
      int xDuration = ((s.x - closestXposToDialog).abs() * 100).round();
      int yDuration = ((s.y - breakY).abs() * 100).round();

      int durationMs = xDuration + yDuration;

      int finalDur = durationMs + 250;
      if (finalDur > longestDurationMs) longestDurationMs = finalDur;
      Duration duration = Duration(milliseconds: finalDur);
      // if (startLeft > 0) {
      //   startLeft -= widget.tileSize;
      // } else if (startLeft < 0) {
      //   startLeft += widget.tileSize;
      // }

      //kolla så det är rätt kanske måste ta minus en halv tilesize eller något? tänkta på padding?

      //lite randomnez till det.
      Icon icon = Icon(PatchworkIcons.button_icon,
          color: buttonColor, size: widget.tileSize);

      children.add(IconMovementAnimation(duration, startLeft * 2, startTop * 2,
          endLeft, endTop, icon, animationCallback));
    }
    int dialogIdleTime = longestDurationMs == 0 ? 1000 : 800;
    Duration closeDialog =
        Duration(milliseconds: longestDurationMs + dialogIdleTime);
    children.add(IconMovementAnimation(
        closeDialog, 10, 10, 0, 0, Icon(null), animationCallback));
    return Stack(
      overflow: Overflow.visible,
      children: children,
    );
  }
}

class IconMovementAnimation extends StatefulWidget {
  final Duration duration;
  final double startLeft;
  final double startTop;
  final double endLeft;
  final double endTop;
  final Icon icon;
  final Function callback;
  IconMovementAnimation(this.duration, this.startLeft, this.startTop,
      this.endLeft, this.endTop, this.icon, this.callback);

  @override
  _IconMovementAnimationState createState() => _IconMovementAnimationState();
}

class _IconMovementAnimationState extends State<IconMovementAnimation>
    with TickerProviderStateMixin {
  AnimationController _ac;
  bool done = false;
  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  void finishUp() {
    widget.callback();
  }

  @override
  Widget build(BuildContext context) {
    if (_ac.isCompleted) {
      return Container();
    }

    _ac.forward().then((x) => finishUp());

    Animation<RelativeRect> animation = new RelativeRectTween(
      begin: new RelativeRect.fromLTRB(
          widget.startLeft, widget.startTop, 0.0, 0.0),
      end: new RelativeRect.fromLTRB(widget.endLeft, widget.endTop, 0.0, 0.0),
    ).animate(new CurvedAnimation(parent: _ac, curve: Curves.easeInExpo));

    return PositionedTransition(
      rect: animation,
      child: widget.icon,
    );
  }
}

class LootBoxAnimation extends StatefulWidget {
  final LootBox lootBox;
  final double tileSize;
  LootBoxAnimation(this.lootBox, this.tileSize);

  @override
  _LootBoxAnimationState createState() => _LootBoxAnimationState();
}

class _LootBoxAnimationState extends State<LootBoxAnimation>
    with TickerProviderStateMixin {
  //AnimationController _ac;
  bool scrollDone;
  bool revealDone;
  ScrollController _controller = new ScrollController();

  @override
  void initState() {
    scrollDone = false;
    super.initState();
    //_ac = AnimationController(vsync: this, duration: Duration(seconds: 3));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void animationCallback() {
    if (!scrollDone) {
      setState(() {
        scrollDone = true;
      });
    } else {
      //om vi vill automatiskt stänga dialogen efter en viss tid, bestämms av Duration closeDialog nedan
      //Navigator.pop(context);
    }

    //delay this a bit. använd två animationcallbacks och först på den andra så popar jag. typ som buttonAnimation?
    //jag kan ha ytterligare en nivå av animation som skickarvidare denna callback.
    //första animation är för scrollgrejen. när den är klar så forward.then så starta nästa animation med winsten.
    //skicka denna callback vidare till den animationen och den kallar tillbaka hela vägen hit som när den är klar popar hela dialogen.
  }

  @override
  Widget build(BuildContext context) {
    //_ac.forward().then((x) => Navigator.pop(context));

    LootPrice win = widget.lootBox.win;
    List<LootPrice> prices = widget.lootBox.prices;
    int winIndex = prices.indexOf(win);
    double lootPriceSize = widget.tileSize * 2;
    double winPos = lootPriceSize * winIndex;
    Random rng = new Random();
    int randomOffset = rng.nextInt((lootPriceSize * 0.8).round());
    double offset = (lootPriceSize / 2) + randomOffset;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!scrollDone) {
        await _controller
            .animateTo(
              (winPos - offset),
              curve: Curves.decelerate,
              duration: const Duration(milliseconds: 5000),
            )
            .whenComplete(animationCallback);
      }

      //animationCallback();
    });

    Duration closeDialog = Duration(milliseconds: 10000);

    return SimpleDialog(
        title: Text(widget.lootBox.getName()),
        children: <Widget>[
          Container(
            width: lootPriceSize * 3,
            child: Column(
              children: <Widget>[
                Container(
                  height: 0,
                  width: 0,
                  child: Stack(
                    children: <Widget>[
                      IconMovementAnimation(closeDialog, 10, 10, 0, 0,
                          Icon(null), animationCallback),
                    ],
                  ),
                ),
                Visibility(
                    visible: scrollDone,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Text("You win " +
                        win.amount.toString() +
                        " " +
                        win.type.toString())),
                Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    Container(
                        width: lootPriceSize * 3,
                        height: lootPriceSize,
                        child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: prices.length,
                            controller: _controller,
                            itemBuilder: (context, index) {
                              LootPrice price = prices[index];
                              return Container(
                                height: lootPriceSize,
                                width: lootPriceSize,
                                child: new Card(
                                  elevation:
                                      scrollDone && index == winIndex ? 3 : 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        price.icon,
                                        size: widget.tileSize,
                                        color: price.color,
                                      ),
                                      Text(
                                        price.amount.toString(),
                                        style: TextStyle(
                                            color: price.color,
                                            fontSize: widget.tileSize / 2),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            })),
                    Positioned(
                      top: -4.0,
                      left: lootPriceSize * 1.5,
                      height: lootPriceSize + 8.0,
                      child: Container(
                        width: 3.0,
                        color: lootBoxColor,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ]);
  }
}

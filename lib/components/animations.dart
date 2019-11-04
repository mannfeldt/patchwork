import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/models/lootBox.dart';
import 'package:patchwork/models/lootPrice.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/utilities/patchwork_icons_icons.dart';

class ButtonAnimation extends StatefulWidget {
  final Player player;
  final double tileSize;
  ButtonAnimation(this.player, this.tileSize);

  @override
  _ButtonAnimationState createState() => _ButtonAnimationState();
}

class _ButtonAnimationState extends State<ButtonAnimation>
    with TickerProviderStateMixin {
  int buttonsnr;
  bool showIcon;

  @override
  void initState() {
    buttonsnr = widget.player.buttons;
    showIcon = false;
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    List<Square> buttonSquares =
        widget.player.board.squares.where((s) => s.hasButton).toList();
    List<Widget> children = [];
    children.add(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Hero(
              tag: "buttonanimationemoji",
              child: new Material(
                color: Colors.transparent,
                child: Text(
                  widget.player.emoji + " ",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            Hero(
              tag: "buttonanimationname",
              child: new Material(
                color: Colors.transparent,
                child: Text(
                  widget.player.name,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
              ),
            ),
          ],
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Hero(
              tag: "buttonanimationscore",
              child: Text(
                buttonsnr.toString(),
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Colors.black87),
              ),
            ),
            Hero(
              tag: "buttonanimationscoreicon",
              child: Icon(
                PatchworkIcons.button_icon,
                color: buttonColor,
                size: widget.tileSize,
              ),
            ),
          ],
        ),
      ],
    ));
    int longestDurationMs = 0;
    int maxAnimationDurationMS = 1500;
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

      int closestXposToDialog = 4;
      int xDuration = ((s.x - closestXposToDialog).abs() * 70).round();
      int yDuration = ((s.y - breakY).abs() * 70).round();

      int durationMs = xDuration + yDuration;

      int finalDur = durationMs + 300;
      finalDur = min(finalDur, maxAnimationDurationMS);
      if (finalDur > longestDurationMs) longestDurationMs = finalDur;
      Duration duration = Duration(milliseconds: finalDur);
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
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: SimpleDialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Stack(
          overflow: Overflow.visible,
          children: children,
        ),
        contentPadding: EdgeInsets.all(15.0),
      ),
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
  bool scrollDone;
  bool revealDone;
  ScrollController _controller = new ScrollController();

  @override
  void initState() {
    scrollDone = false;
    super.initState();
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
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    LootPrice win = widget.lootBox.win;
    List<LootPrice> prices = widget.lootBox.prices;
    int winIndex = prices.indexOf(win);
    double lootPriceSize = widget.tileSize * 2;
    double winPos = lootPriceSize * winIndex;
    Random rng = new Random();
    int randomOffset = rng.nextInt((lootPriceSize * 0.7).round());
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
    });

    Duration closeDialog = Duration(seconds: 7);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: SimpleDialog(
          elevation: 0,
          title: Text(
            widget.lootBox.getName(),
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 1.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 2.0,
                    color: Color.fromARGB(125, 0, 0, 255),
                  ),
                ],
                color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          children: <Widget>[
            Container(
              decoration: new BoxDecoration(
                color: Colors.transparent,
              ),
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
                  Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [0, 0.05, 0.5, 0.95, 1],
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(1),
                              Colors.white.withOpacity(1),
                              Colors.white.withOpacity(1),
                              Colors.white.withOpacity(0),
                            ],
                          ).createShader(
                              Rect.fromLTRB(0, 0, rect.width, rect.height));
                        },
                        child: Container(
                            decoration: new BoxDecoration(
                              color: Colors.transparent,
                            ),
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
                                      elevation: scrollDone && index == winIndex
                                          ? 1
                                          : 3,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                        blendMode: BlendMode.dstATop,
                      ),
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
          ]),
    );
  }
}

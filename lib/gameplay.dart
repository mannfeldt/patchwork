import 'dart:math';

import 'package:flutter/material.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/dialogs.dart';
import 'package:patchwork/footer.dart';
import 'package:patchwork/gameBoard.dart';
import 'package:patchwork/models/announcement.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/models/square.dart';
import 'package:patchwork/patchSelector.dart';
import 'package:patchwork/patchwork_icons_icons.dart';
import 'package:patchwork/timeGameBoard.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/gamestate.dart';

class Gameplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Announcement announcement = gameState.getAnnouncement();
      bool isButtonsAnimation = gameState.getButtonsAnimation();
      bool doneanimation = false;
      if (announcement != null) {
        switch (announcement.type) {
          case AnnouncementType.snackbar:
            Dialogs.snackbar(context, announcement);
            break;
          case AnnouncementType.simpleDialog:
            Dialogs.simpleAnnouncement(context, announcement);
            break;
          case AnnouncementType.dialog:
            Dialogs.announcement(context, announcement);
            break;
          default:
            break;
        }
        gameState.clearAnnouncement();
      }
      if (isButtonsAnimation && !doneanimation) {
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SimpleDialog(
                  backgroundColor: Colors.transparent,
                  contentPadding: EdgeInsets.all(0),
                  elevation: 0,
                  title: ButtonAnimation(gameState.getCurrentPlayer(),
                      gameState.getBoardTileSize()),
                ));
          },
        );
        doneanimation = true;
        await gameState.clearAnimationButtons(true);
        doneanimation = false;
      }
    });

// TODO se nedan
    // refactorisera. nya widgetar. flytta metoder till rule engine, util osv? lägg till constanter istället för hårdkodade värden

    //2. lägg till fler game mechanics. försten till 7x7. skriv bara ut en alert eller dialog ruta. skapa en generell ruta för händelser
    //3. skriv då att player x fick 7x7. sätt player.svenbysven = true och så räknas det i ruleEngine.countScore

    // jag har många ideet om gamemodes osv. vill inte lägg in allt i ett mode.
    //ska några modes eller ha standard och wild där man kan få välja av och på massa inställnignar?

    //hur hanterar jag detta bra i logiken? massa booleans och ifsatser? best practices kolla på.

    //koll min google keep efter de bästa kandidaterna till gamemodes / mechanics jag vill ha.

    //sax är coolt. bingo är lättare

    //kan best practice är att ha en enumlista med "gamemodes" och ha ifsatser/kollar där det behövs på om gamestate.hasGameMode("xx");

    return SafeArea(
      child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        // constraints variable has the size info
        gameState.setConstraints(constraints.maxWidth, constraints.maxHeight);
        double boardTileSize = gameState.getBoardTileSize();
        Player currentPlayer = gameState.getCurrentPlayer();
        Player previousPlayer = gameState.getPreviousPlayer();
        bool isEvenId = gameState.getTurnCounter().isEven;
        Random rng = new Random();
        print("NOTIFYED" + rng.nextInt(100).toString());
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(
                    gameBoardInset, gameBoardInset, gameBoardInset, 0),
                child: AnimatedCrossFade(
                  firstCurve: Curves.easeIn,
                  secondCurve: Curves.easeIn,
                  firstChild: GameBoard(
                    board:
                        isEvenId ? currentPlayer.board : previousPlayer.board,
                  ),
                  secondChild: GameBoard(
                    board:
                        !isEvenId ? currentPlayer.board : previousPlayer.board,
                  ),
                  crossFadeState: isEvenId
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: Duration(seconds: 1),
                ),
                height: constraints.maxWidth,
              ),
              Container(
                child: PatchSelector(),
                height: gameState.getPatchSelectorHeight(),
              ),
              Container(
                child: TimeGameBoard(),
                height: boardTileSize != null ? boardTileSize / 1.2 : 0,
              ),
              Container(
                child: Footer(),
                height: boardTileSize ?? 0,
              )
            ],
          ),
        );
      }),
    );
  }
}

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
  int buttonsnr = 0;

  @override
  void initState() {
    super.initState();
    //_ac = AnimationController(vsync: this, duration: Duration(seconds: 3));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void animationCallback() {
    if (widget.player.board.buttons == buttonsnr) {
      Navigator.pop(context);
    } else {
      setState(() {
        buttonsnr += 1;
      });
    }
    //om den är lika med player.board.buttons så är den klar. vill vi göran ågot mer då?
    //stänga allt med pop?

    //jag skulle kunna ha en osvynlig sista knapp som animeras med en längre duration coh när den når denna callback så kör jag pop
    //den kan ligga på 1 sekund över och när vi kommer hit och buttonsnr redan är = player.board-buttson så stänger vi istället
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
            Text(" x" + buttonsnr.toString()),
            IndexedStack(
              index: buttonsnr > 0 ? 0 : 1,
              children: <Widget>[
                Icon(
                  PatchworkIcons.button_icon,
                  color: buttonColor,
                  size: widget.tileSize,
                ),
                Icon(
                  PatchworkIcons.button_icon,
                  color: Colors.transparent,
                  size: widget.tileSize,
                )
              ],
            )
          ],
        ),
      ],
    ));
    int longestDurationMs = 0;
    for (int i = 0; i < buttonSquares.length; i++) {
      Square s = buttonSquares[i];

      Random rng = new Random();
      int rngMs = rng.nextInt(200);
      int closestXposToDialog = 4;
      int closestYposToDialog = 8;
      int xDuration = ((s.x - closestXposToDialog).abs() * 100).round();
      int yDuration = ((s.y - closestYposToDialog).abs() * 100).round();

      int durationMs = xDuration + yDuration;

      int finalDur = durationMs + 100 + rngMs;
      if (finalDur > longestDurationMs) longestDurationMs = finalDur;
      Duration duration = Duration(milliseconds: finalDur);

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
    int dialogIdleTime = 500;
    Duration closeDialog = Duration(milliseconds: longestDurationMs + dialogIdleTime);
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
    ).animate(new CurvedAnimation(parent: _ac, curve: Curves.bounceOut));

    return PositionedTransition(
      rect: animation,
      child: widget.icon,
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:patchwork/animations.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/dialogs.dart';
import 'package:patchwork/footer.dart';
import 'package:patchwork/gameBoard.dart';
import 'package:patchwork/models/announcement.dart';
import 'package:patchwork/models/lootBox.dart';
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
    double boardTileSize = gameState.getBoardTileSize();
    Player currentPlayer = gameState.getCurrentPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Announcement announcement = gameState.getAnnouncement();
      bool isButtonsAnimation = gameState.getButtonsAnimation();
      bool isBingoAnimation = gameState.getBingoAnimation();
      LootBox lootBox = gameState.getLootBox();
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
      if (isBingoAnimation && !doneanimation) {
        gameState.setBingoAnimation(false);
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return LootBoxAnimation(lootBox, gameState.getBoardTileSize());

            // return GestureDetector(
            //         onTap: () {
            //           Navigator.pop(context);
            //         },
            //         child: SimpleDialog(
            //           contentPadding: EdgeInsets.all(15.0),
            //           children: <Widget>[
            //             Container(
            //                 width: 400,
            //                 child: LootBoxAnimation(
            //                     lootBox, gameState.getBoardTileSize()))
            //           ],
            //           title: Text("titleeee"),
            //           titlePadding: EdgeInsets.all(15.0),
            //         ));
          },
        );

        doneanimation = true;
        //skicka tillbaka resultatet från lootboxen här? och hantera det i gamestate?
        await gameState.handleBingoAnimationEnd();
        doneanimation = false;
      }
      if (isButtonsAnimation && !doneanimation) {
        if (currentPlayer.board.buttons > 0) {
          await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SimpleDialog(
                    title: ButtonAnimation(
                        currentPlayer, gameState.getBoardTileSize()),
                    titlePadding: EdgeInsets.all(15.0),
                  ));
            },
          );
        }
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

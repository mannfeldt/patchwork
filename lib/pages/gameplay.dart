import 'dart:math';

import 'package:flutter/material.dart';
import 'package:patchwork/components/animations.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:patchwork/components/dialogs.dart';
import 'package:patchwork/components/footer.dart';
import 'package:patchwork/components/gameBoard.dart';
import 'package:patchwork/models/announcement.dart';
import 'package:patchwork/models/lootBox.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/components/patchSelector.dart';
import 'package:patchwork/components/timeGameBoard.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/logic/gamestate.dart';

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
          barrierDismissible: false,
          builder: (BuildContext context) {
            return LootBoxAnimation(lootBox, gameState.getBoardTileSize());
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

    Player previousPlayer = gameState.getPreviousPlayer();
    bool isEvenId = gameState.getTurnCounter().isEven;
    Random rng = new Random();
    print("NOTIFIED " + rng.nextInt(100).toString());
    bool useLootboxes = gameState.getGameMode() == GameMode.BINGO;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(
                gameBoardInset, gameBoardInset, gameBoardInset, 0),
            child: AnimatedCrossFade(
              firstCurve: Curves.easeIn,
              secondCurve: Curves.easeIn,
              firstChild: GameBoard(
                  board: isEvenId ? currentPlayer.board : previousPlayer.board,
                  useLootboxes: useLootboxes,
                  tileSize: boardTileSize),
              secondChild: GameBoard(
                  board: !isEvenId ? currentPlayer.board : previousPlayer.board,
                  useLootboxes: useLootboxes,
                  tileSize: boardTileSize),
              crossFadeState: isEvenId
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: Duration(seconds: 1),
            ),
            height: boardTileSize * 9,
          ),
          Container(
            child: PatchSelector(),
            height: gameState.getPatchSelectorHeight(),
          ),
          Container(
            child: TimeGameBoard(),
            height: boardTileSize / 1.2,
          ),
          Container(
            child: Footer(),
            height: boardTileSize ?? 0,
          )
        ],
      ),
    );
  }
}

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:patchwork/components/animations.dart';
import 'package:patchwork/components/tutorialPages.dart';
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
import 'package:screenshot/screenshot.dart';
import 'package:showcaseview/showcaseview.dart';

class Gameplay extends StatefulWidget {
  @override
  _GameplayState createState() => _GameplayState();
}

class _GameplayState extends State<Gameplay> {
  GlobalKey _gameBoardTutorialKey = GlobalKey();
  GlobalKey _patchesTutorialKey = GlobalKey();
  GlobalKey _timeBoardTutorialKey = GlobalKey();
  GlobalKey _passTutorialKey = GlobalKey();
  GlobalKey _cashTutorialKey = GlobalKey();
  GlobalKey _nameTutorialKey = GlobalKey();

  ScreenshotController screenshotController = ScreenshotController();

  bool tutorialPlayed = false;
  bool isScreenshotTaken = false;
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    double boardTileSize = gameState.getBoardTileSize();
    Player currentPlayer = gameState.getCurrentPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!isScreenshotTaken && currentPlayer.state == "Waiting_screenshot") {
        setState(() {
          isScreenshotTaken = true;
        });
        await Future.delayed(Duration(milliseconds: 300));
        File image = await screenshotController.capture();
        gameState.saveScreenshot(image);
        setState(() {
          isScreenshotTaken = false;
        });
      }
      if (currentPlayer.state != "Waiting_screenshot" &&
          currentPlayer.state != "finished") {
        bool playTutorial = await gameState.isPlayTutorial();
        if (playTutorial && !tutorialPlayed) {
          tutorialPlayed = true;
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return TutorialPages(
                gameMode: gameState.getGameMode(),
              );
            },
          );

          ShowCaseWidget.of(context).startShowCase([
            _gameBoardTutorialKey,
            _patchesTutorialKey,
            _timeBoardTutorialKey,
            _nameTutorialKey,
            _cashTutorialKey,
            _passTutorialKey
          ]);
        }

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

          await Navigator.of(context).push(
            PageRouteBuilder(
                pageBuilder: (_context, _, __) =>
                    LootBoxAnimation(lootBox, gameState.getBoardTileSize()),
                opaque: false),
          );

          doneanimation = true;
          gameState.handleBingoAnimationEnd();
          doneanimation = false;
        }
        if (isButtonsAnimation && !doneanimation) {
          if (currentPlayer.board.buttons > 0) {
            await Navigator.of(context).push(
              PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 300),
                  pageBuilder: (_context, _, __) => ButtonAnimation(
                      currentPlayer, gameState.getBoardTileSize()),
                  opaque: false),
            );
          }
          doneanimation = true;
          gameState.onButtonAnimationRecievedButtons();
          if (currentPlayer.board.buttons > 0) {
            await Future.delayed(Duration(milliseconds: 600));
          }

          gameState.onButtonAnimationCompleted();
          doneanimation = false;
        }
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
          Showcase(
            key: _gameBoardTutorialKey,
            title: "Game board",
            textColor: Colors.white,
            showcaseBackgroundColor: buttonColor,
            description: useLootboxes
                ? 'This is where you place your patches.\nCompleting a row in same color awards you with a lootbox.'
                : 'This is where you place your patches',
            child: Container(
              padding:
                  EdgeInsets.fromLTRB(gameBoardInset, 0, gameBoardInset, 0),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 50),
                curve: Curves.easeIn,
                opacity: isScreenshotTaken ? 0.1 : 1,
                child: Screenshot(
                  controller: screenshotController,
                  child: AnimatedCrossFade(
                    firstCurve: Curves.easeIn,
                    secondCurve: Curves.easeIn,
                    firstChild: GameBoard(
                        board: isEvenId
                            ? currentPlayer.board
                            : previousPlayer.board,
                        useLootboxes: useLootboxes,
                        tileSize: boardTileSize),
                    secondChild: GameBoard(
                        board: !isEvenId
                            ? currentPlayer.board
                            : previousPlayer.board,
                        useLootboxes: useLootboxes,
                        tileSize: boardTileSize),
                    crossFadeState: isEvenId
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: Duration(seconds: 1),
                  ),
                ),
              ),
              height: boardTileSize * 9,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0,
                gameState.getPatchSelectorHeight() - boardTileSize * 4),
            child: Container(
              child: Showcase(
                key: _patchesTutorialKey,
                textColor: Colors.white,
                showcaseBackgroundColor: buttonColor,
                title: "Patches",
                description:
                    'Here you select a patch to drag and drop onto your game board.\nYou can rotate and flip the patches. \nEach patch costs buttons and time.',
                child: PatchSelector(),
              ),
              height: boardTileSize * 4,
            ),
          ),
          Showcase(
            key: _timeBoardTutorialKey,
            textColor: Colors.white,
            showcaseBackgroundColor: buttonColor,
            title: "Timeline",
            description:
                'This displays players positions and upcomming events.',
            child: Container(
              child: TimeGameBoard(),
              height: boardTileSize / 1.2,
            ),
          ),
          Container(
            child: Footer(
                passKey: _passTutorialKey,
                cashKey: _cashTutorialKey,
                nameKey: _nameTutorialKey),
            height: boardTileSize ?? 0,
          ),
        ],
      ),
    );
  }
}

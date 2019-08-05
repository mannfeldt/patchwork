import 'package:flutter/material.dart';
import 'package:patchwork/mainMenu.dart';
import 'package:patchwork/gameplay.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/gamestate.dart';
import 'package:flutter/services.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider<GameState>(
        builder: (_) => GameState("test123"),
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  String _previousPhase;
  //skapa en koppling till game.dart som state?
  //använd funktionerna i game.fetchgame/joingame till en knapp här
  //sen ska ju denna widget bara visas om golfgame är null.
  //annars ska widget lobby eller gameplay visas beroende på vad phase är.
  //denna wdiget är parent som håller state, lobby och gameplay är childs som jag kan passa state till och renderare rätt child beroende på state i parent här.
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    //Golfgame golfgame = gameState.getGame();
    // Widget child;
    // if (golfgame == null) {
    //   //phase == level_completed?
    //   child = Connect();
    // } else if (golfgame.phase == "connection") {
    //   child = Lobby();
    // } else if (golfgame.phase == "starting") {
    //   child = Center(child: Text("Starting.."));
    // } else if (golfgame.phase == "gameplay" ||
    //     golfgame.phase == "level_completed") {
    //   if (_previousPhase == "level_completed" && golfgame.phase == "gameplay") {
    //     gameState.nextLevel();
    //   }
    //   child = GolfController();
    // } else {
    //   child = Text("ERROR GAME PHASE WRONG?");
    // }
    //_previousPhase = golfgame != null ? golfgame.phase : null;
    Widget child = MainMenu();
    //detta funkar inte. hur får jag provider i flera heirarkeier? hur kan jag använda state till att välja vilken widget som ska

    return Scaffold(
      appBar: AppBar(
        title: Text(gameState.getGameId()),
      ),
      body: child,
    );
  }
}

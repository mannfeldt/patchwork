import 'package:flutter/material.dart';
import 'package:patchwork/logic/highscoreState.dart';
import 'package:patchwork/pages/endScreen.dart';
import 'package:patchwork/pages/mainMenu.dart';
import 'package:patchwork/pages/gameplay.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/logic/gamestate.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcase_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (_) => GameState()),
        ChangeNotifierProvider(builder: (_) => HighscoreState()),
      ],
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: HomePage()),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final highscoreState = Provider.of<HighscoreState>(context);
    if (highscoreState.getAllHightscores() == null) {
      highscoreState.fetchHighscores();
    }
    final view = gameState.getView();
    Widget child;
    bool showAppBar = true;
    if (view == null) {
      child = MainMenu();
    } else if (view == "gameplay") {
      child =
          ShowCaseWidget(builder: Builder(builder: (context) => Gameplay()));
      showAppBar = false;
    } else if (view == "finished") {
      child = EndScreen();
      showAppBar = false;
    } else {
      child = Text("Loading...");
    }
    return new WillPopScope(
        onWillPop: () {
          return new Future(() => false);
        },
        child: Scaffold(
            appBar: showAppBar
                ? AppBar(
                    title: Text("Patchwork"),
                  )
                : null,
            body: SafeArea(
              child: new LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                gameState.setConstraints(
                    constraints.maxWidth, constraints.maxHeight);
                return child;
              }),
            )));
  }
}

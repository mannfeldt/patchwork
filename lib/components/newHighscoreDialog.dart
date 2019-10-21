import 'package:flutter/material.dart';
import 'package:patchwork/logic/gamestate.dart';
import 'package:patchwork/models/highscore.dart';
import 'package:provider/provider.dart';
//används inte?
class NewHighscoreDialog extends StatefulWidget {
  final Highscore highscore;

  NewHighscoreDialog({this.highscore});

  @override
  _NewHighscoreDialogState createState() => _NewHighscoreDialogState();
}

class _NewHighscoreDialogState extends State<NewHighscoreDialog> {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    return AlertDialog(
        contentPadding: EdgeInsets.all(2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //namnet ska hamna i en inputruta där man kan justera det.
            //score ska visas som det gör i end screen. skapa en widiget för det utseendet som även kan anvndas i highscoreTable
            //den här dialogen kanske ska vara en variant av highscoreTable där man får se sin placering och kan ändra namnet innan det sparas.
            //annars får jag ändå räkna ut vilken placering detta highscore har.
            //jag kan bara se till att rendrera en tabell där jag hämtar alla highscores och lägger till detta nya på sin givna plats.
            //eller så skriver jag bara ut vilken placering man fått all time / wekkly / monthly

            //sno lite från highscoreTable widgeten. Ändra så att namnet är editerbart.
            //lägg till en spara knapp
            //det är tablet för den bästa placeringen som ska visas. Om man är med på all time visas den. om man är med på monthly visas den annars weekly.
            //när jag hämtar newHighscores från gamestate så lägg till highscore.table = "WEEKLY" t.ex.
            //sen här får jag kolla på det värdet och renderar rätt table ut efter det.
            //hämta highscore data här eller kan jag få in det till denna kolumn. så jag får in ett newHighscore, och en lista på befinltiga highscores i samma kategori
            //då kan jag bara skapa ett enkelt table
            Text("name:" + widget.highscore.name),
            Text("score:" + widget.highscore.score.toString()),
            Text("time:" + widget.highscore.time.toString()),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: new SizedBox(
                width: double.infinity,
                // height: double.infinity,
                child: RaisedButton(
                    child: Text("Save"),
                    onPressed: () {
                      // gameState.saveHighscore(widget.highscore);
                      Navigator.of(context).pop();
                    }),
              ),
            )
          ],
        ));
  }
}

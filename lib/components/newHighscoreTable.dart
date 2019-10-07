import 'package:flutter/material.dart';
import 'package:patchwork/components/scoreBubbles.dart';
import 'package:patchwork/models/highscore.dart';
import 'package:patchwork/utilities/constants.dart';

//TODO
//tsta vad som är fel nu
//försök få in så att highscore dialog två har fått den första dialogens tillägg. krävs bara nytt anrop till highscoreprovidern för att få in de senaste fårn _highscore
//hur ska det sorteras? samma score så ska man komma in på listan för dem tidigare?
//lägg tillbaka timeline fokus. så att den autoscrollar till spelaren. nu är det bortkommenterat

//det blir kanske lätt att överföra detta till "online"? behöver bara bry sig om en spelare egentligen då. alt kan man visa att den andra spelaren slog rekord genom någon ikon i endscreen tabellen också
//LÄGG TILL DET NU! någon guldmedalj som säger vilken plats man är all_time? inte weekeyl
// kolla på markellas PR
//när allt detta är på plats så pusha ut det till app store.
//sen börja jobba på screenshot biten
//och efter det på onlinebiten. user login friendlist. fix in kanban prioritize, whats for the first version of online?
//friendlist could have online status etc later on.
//föslag till första onlineversion: du kan logga in via fb/google/anonymt
// varje användare får ett uniktID eller får skapa ett användarnamn. anonyma blir tilldelade ett?
// när man väljer att starta ett game så finns nu en knapp för online. i setupen för den så kan man då invita baserat på användarnamn
//friendlist kommer senare)
//när man invitar så får den invitade personen en notifikation och kan gå in i appen och se invites i en lista eller liknande
//(får nog införa bottom navbar precis som PE) där kan man välj att accepter eller declina.
//vad man än gör så notifieras hosten om det.
//när hosten skapat ett game inkl vilka han vill invita så sparas get spelet med ett nytt state.
//spel med det statet kan ses i en annan vy där man kan se pågående spel,
//där kan han följa vilka som svarat ja och nej osv och välja att starta spelet när som helst när minst två spelare är med
//när spelet startas får båda en notifikation och det är alltid någon av dem som börjar.
//nofikation när det är ens tur osv.
//låsa spelplanen så bara currentplayer kan göra moves.
//man ska kunna swapa mellan alla gameboards för att se anvdras.
//behöver i första hand klura ut hur datastrukturen ska se ut för att spara ner state på players gameboards.
//vill jag skilja gameboard widgetarna mellan gameboard och onlinegameboard? samma med många andra widgetar? eller vill jag skapa ifsatser kolla flaggor osv i befintliga?
//hur hanterar jag att man fortfarande ska kunna spela local
//får ta fram en plan börja på en ny branch.
//jag ser att det kanske blir en onlineGameState som är kopplat till en API klass som sköter alla anrop till firebase. kanske också en onlineGameplay widget osv.

class NewHighscoreTable extends StatefulWidget {
  final List<Highscore> highscores;
  final Highscore newHighscore;
  final Function callbackSaveHighscore;
  NewHighscoreTable(
      {this.highscores, this.callbackSaveHighscore, this.newHighscore});

  @override
  _NewHighscoreTableState createState() => _NewHighscoreTableState();
}

class _NewHighscoreTableState extends State<NewHighscoreTable> {
  TextEditingController nameController = new TextEditingController();
  @override
  void initState() {
    nameController.text = widget.newHighscore.name;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: <Widget>[
                DataTable(
                    dataRowHeight: 60.0,
                    columnSpacing: 20.0,
                    columns: <DataColumn>[
                      DataColumn(
                        label: Text('Name'),
                      ),
                      DataColumn(
                        label: Text('Score'),
                      )
                    ],
                    rows: widget.highscores
                        .asMap()
                        .map((index, highscore) => MapEntry(
                              index,
                              DataRow(
                                cells: [
                                  DataCell(Container(
                                    color: index >= highscoreLimit
                                        ? Colors.red
                                        : Colors.transparent,
                                    child: highscore.isNew
                                        ? TextField(
                                            controller: nameController,
                                            maxLength: 12,
                                          )
                                        : Text(highscore.name),
                                  )),
                                  DataCell(ScoreBubbles(
                                    plus: highscore.score,
                                    minus: highscore.scoreMinus,
                                    extra: highscore.scoreExtra,
                                    total: highscore.score -
                                        highscore.scoreMinus +
                                        highscore.scoreExtra,
                                  ))
                                ],
                              ),
                            ))
                        .values
                        .toList()),
                RaisedButton(
                  onPressed: () {
                    if (widget.callbackSaveHighscore != null) {
                      widget.callbackSaveHighscore(
                          widget.newHighscore, nameController.text);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text("Save"),
                )
              ],
            )));
  }
}

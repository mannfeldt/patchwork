import 'package:flutter/material.dart';
import 'package:patchwork/components/scoreBubbles.dart';
import 'package:patchwork/models/highscore.dart';
import 'package:patchwork/models/player.dart';
import 'package:patchwork/utilities/constants.dart';

//TODO
//tsta vad som är fel nu
//försök få in så att highscore dialog två har fått den första dialogens tillägg. krävs bara nytt anrop till highscoreprovidern för att få in de senaste fårn _highscore
//hur ska det sorteras? samma score så ska man komma in på listan för dem tidigare?
//lägg tillbaka timeline fokus. så att den autoscrollar till spelaren. nu är det bortkommenterat. återsätll calculateScore och finishTile i boardtile som är väldigt låg nu

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
  final Player player;
  NewHighscoreTable(
      {this.highscores,
      this.callbackSaveHighscore,
      this.newHighscore,
      this.player});

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: widget.highscores.length,
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.black87,
                );
              },
              itemBuilder: (context, index) {
                Highscore highscore = widget.highscores[index];
                int score = highscore.getTotal();

                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(right: 24),
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(fontSize: 20, color: Colors.blue),
                          )),
                      highscore.isNew
                          ? Image.file(widget.player.screenshot)
                          : FadeInImage.assetNetwork(
                              image: highscore.thumbnail,
                              fadeOutDuration: Duration(milliseconds: 200),
                              fadeInDuration: Duration(milliseconds: 400),
                              placeholder:
                                  "assets/Ring-Preloader.gif", //här ska vi ha en annan placeholder. typ en gif loader?
                            ),
                    ],
                  ),
                  title: highscore.isNew
                      ? TextField(
                          controller: nameController,
                          maxLength: 12,
                          style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w400),
                        )
                      : Text(
                          highscore.name,
                          style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w400),
                        ),
                  trailing: CircleAvatar(
                    backgroundColor: score < 0 ? Colors.red : Colors.blue,
                    child: Text(
                      score.abs().toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
        ),

        //här vill jag visa thumbnails. kanske innan namnet? kanske ska skippa att det är ett datatable och bara använda listview?
        //same as endScreen.
        //add function to klick and view full size image (only in highscoreMenu?)
        //instead of the roundBoubles make small graf? like stapeldiagram that shows plus minut extra in 3 colors
        //väldigt liten. lika bred som hög. som en ikon.
        //så vi har namn, thumnail, score, stapeldiagram.
        //stapeldiagram och score ligger brevidvarandra. bilden llängst till höger troligen.
        //stapeldiagramet är nice to have bara. senare grej

        //if highscore.isNew så visa player.screenshot istället
        //! ta in markellas ändringar. kopiera dem, merga inte då det är lite annat där också. ta bort bilder och ta backgrunden samt nya highscoreknappen
        //ser det bra ut med den bilden? behåll den om det ser ok ut. annars gör om. jag gillar den lila bilden. gör den rundad och med en bubbla som PE har i en annan nyans av lila
        //testa kör samma fade effekt på lila bilden.

        //!skapa en listview istället för datatable. ingen rubrik då det är självförklarande
        //! title: namn
        //!subtitle: datum
        //!trailing: thumbnail. kanske byter plats på thumbnail och score
        //! leading: totalScore (visa i en svarvit bubbla? lila vit bubbla? något annat sätt?) BOLD
        //! raden ska vara clickbar i highscoretable (inte new)
        //! där får man upp en mer detaljerad vy. med scoreBubbles eller stapeldiagram, större screenshot,
        //! är screenshoten "osynlig" så är det bra. blinkar det till eller r deplay så gör det till en grej. lägg lite mer delay och lägg till en blixt eller liknande kanske
        //verkar vara lite olika. pieces blir vita ibland också? är det för att de inte hinner rendreras innan asyncgrejen kommer som tar screenshotet? lägga till lite väntetid? wait delayed?

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(right: 8.0, top: 16.0, bottom: 8.0),
              child: FlatButton(
                textColor: Colors.blue,
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: Text("Skip"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: .0, top: 16.0, bottom: 8.0),
              child: RaisedButton(
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () async {
                  if (widget.callbackSaveHighscore != null) {
                    await widget.callbackSaveHighscore(widget.newHighscore,
                        nameController.text, widget.player);
                  }
                  Navigator.of(context).pop();
                },
                child: Text("Save"),
              ),
            ),
          ],
        )
      ],
    );
  }
}

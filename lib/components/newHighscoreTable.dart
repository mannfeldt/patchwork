import 'package:flutter/material.dart';
import 'package:patchwork/models/highscore.dart';
import 'package:patchwork/models/player.dart';

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
                              placeholder: "assets/transparent.png",
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
              padding:
                  const EdgeInsets.only(right: 16.0, top: 16.0, bottom: 8.0),
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

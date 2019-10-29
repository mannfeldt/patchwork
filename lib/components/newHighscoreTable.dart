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
  ScrollController _scrollController = new ScrollController();

  bool isSaving = false;
  bool disableSave = false;
  @override
  void initState() {
    String playerName = widget.newHighscore.name.toUpperCase();
    playerName =
        playerName.length > 3 ? playerName.substring(0, 3) : playerName;
    nameController.text = playerName;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.highscores.length > 2) {
        int scrollpos = widget.highscores.indexWhere((h) => h.isNew) - 2;
        await _scrollController.animateTo(
          (scrollpos.toDouble() * 60),
          curve: Curves.easeOut,
          duration: Duration(milliseconds: 200 + (scrollpos * 100)),
        );
      }
    });

    bool disableSave =
        nameController.text.length != 3 || widget.callbackSaveHighscore == null;
    final mq = MediaQuery.of(context);
    return Stack(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 300 - mq.viewInsets.bottom,
          ),
          child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: 80),
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
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

                return Container(
                  height: 60,
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(right: 24),
                            child: Text(
                              (index + 1).toString(),
                              style:
                                  TextStyle(fontSize: 20, color: Colors.blue),
                            )),
                        highscore.isNew
                            ? Image.file(widget.player.screenshot)
                            : FadeInImage.assetNetwork(
                                image: highscore.screenshot,
                                fadeOutDuration: Duration(milliseconds: 200),
                                fadeInDuration: Duration(milliseconds: 400),
                                placeholder: "assets/transparent.png",
                              ),
                      ],
                    ),
                    title: highscore.isNew
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8, right: 8),
                                  child: Text(
                                    highscore.emoji,
                                    style: TextStyle(
                                        fontSize: 20,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: nameController,
                                    onChanged: nameChanged,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    maxLength: 3,
                                    style: TextStyle(
                                        fontSize: 20,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w400),
                                  ),
                                )
                              ])
                        : Text(
                            highscore.displayname,
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
                  ),
                );
              }),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(right: 8.0, top: 16.0, bottom: 8.0),
                child: RaisedButton(
                  textColor: Colors.blue,
                  color: Colors.white,
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
                  color: disableSave
                      ? Colors.grey
                      : isSaving ? Colors.white : Colors.blue,
                  textColor: Colors.white,
                  onPressed: () async {
                    if (!disableSave && !isSaving) {
                      setState(() {
                        isSaving = true;
                      });
                      await widget.callbackSaveHighscore(widget.newHighscore,
                          nameController.text, widget.player);
                      setState(() {
                        isSaving = false;
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        )
                      : Text("Save"),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void nameChanged(String value) {
    setState(() {
      disableSave = value.length != 3;
    });
  }
}

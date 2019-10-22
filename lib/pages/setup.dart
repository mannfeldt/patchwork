import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:patchwork/utilities/constants.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/logic/gamestate.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_colorpicker/utils.dart';
import 'package:patchwork/models/player.dart';

class Setup extends StatefulWidget {
  final GameMode gameMode;
  Setup({this.gameMode});
  @override
  SetupState createState() {
    return SetupState();
  }
}

class SetupState extends State<Setup> {
  Color _pickerColor;
  TextEditingController nameController = TextEditingController();
  bool _isAi = false;
  bool _playTutorial;

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_playTutorial == null) {
        bool firstGame = await gameState.isFirstGame();
        setState(() {
          _playTutorial = firstGame;
        });
      }
    });
    List<Player> players = gameState.getPlayers();
    List<Color> usedColors = players.map((p) => p.color).toList();
    List<Color> availableColors =
        playerColors.where((color) => !usedColors.contains(color)).toList();
    if (_pickerColor == null) {
      Random rng = new Random();
      _pickerColor = availableColors[rng.nextInt(availableColors.length)];
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("New " + gameModeName[widget.gameMode] + " Game"),
        ),
        body: Builder(
            builder: (context) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Switch(
                                activeColor: Colors.green.shade700,
                                onChanged: _onSwitchChanged,
                                value: _playTutorial ?? false,
                              ),
                              Text("Show Tutorial"),
                            ],
                          ),
                          RaisedButton(
                            color: buttonColor,
                            onPressed: () {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              Scaffold.of(context).hideCurrentSnackBar();
                              if (players.length < minimumPlayers) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text("Needs at least " +
                                        minimumPlayers.toString() +
                                        " players to start")));
                              } else {
                                gameState.startGame(
                                    widget.gameMode, _playTutorial);
                                Navigator.pop(context, null);
                              }
                            },
                            child: Text(
                              "Start",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(2.0, 30.0, 0, 0),
                        child: Text(
                          "Add players",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                        Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.fromLTRB(2.0, 0, 0, 0),
                            child: TextField(
                              controller: nameController,
                              maxLength: 12,
                              decoration: InputDecoration(labelText: 'Name'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: new Padding(
                            padding: const EdgeInsets.fromLTRB(2.0, 0, 0, 0),
                            child: new CheckboxListTile(
                              value: _isAi,
                              onChanged: _aiChanged,
                              dense: true,
                              secondary: new Icon(Icons.android),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Center(
                          child: RaisedButton(
                            elevation: 3.0,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return BackdropFilter(
                                    filter:
                                        ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                    child: AlertDialog(
                                      title: Text('Select a color'),
                                      content: SingleChildScrollView(
                                        child: BlockPicker(
                                          pickerColor: _pickerColor,
                                          onColorChanged: changeColor,
                                          availableColors: availableColors,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: const Text('Color'),
                            color: _pickerColor,
                            textColor: useWhiteForeground(_pickerColor)
                                ? const Color(0xffffffff)
                                : const Color(0xff000000),
                          ),
                        ))
                      ]),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: new Padding(
                            padding:
                                const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                            child: RaisedButton(
                              onPressed: () {
                                if (players.length >= maximumPlayers) {
                                  Scaffold.of(context).hideCurrentSnackBar();
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      content:
                                          Text("Can not add more players")));
                                } else {
                                  gameState.addPlayer(
                                      nameController.text, _pickerColor, _isAi);
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());

                                  nameController.clear();
                                  _pickerColor = null;
                                }
                              },
                              child: Text("Add"),
                            ),
                          ))
                        ],
                      ),
                      Expanded(
                          child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 15.0),
                        child: players != null
                            ? ListView.builder(
                                itemCount: players.length,
                                itemBuilder: (context, index) {
                                  final player = players[index];
                                  return Dismissible(
                                    key: Key(player.id.toString()),
                                    onDismissed: (direction) {
                                      gameState.removePlayer(player);
                                      Scaffold.of(context)
                                          .hideCurrentSnackBar();
                                      Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  player.name + " removed")));
                                    },
                                    background: Container(
                                        color: Colors.deepOrange.shade300),
                                    child: ListTile(
                                      title: Text(player.name),
                                      leading: Icon(
                                          player.isAi
                                              ? Icons.android
                                              : Icons.person,
                                          color: player.color),
                                    ),
                                  );
                                },
                              )
                            : Text("No players",
                                style: TextStyle(
                                    fontSize: 16,
                                    height: 8,
                                    color: Colors.grey)),
                      ))
                    ],
                  ),
                )));
  }

  void _onSwitchChanged(bool value) {
    setState(() => _playTutorial = value);
  }

  void changeColor(Color value) {
    setState(() => _pickerColor = value);
    Navigator.pop(context, null);
  }

  void _aiChanged(bool value) => setState(() => _isAi = value);
}

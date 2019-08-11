import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/ruleEngine.dart';
import 'package:patchwork/gamestate.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_colorpicker/utils.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:patchwork/constants.dart';
import 'package:patchwork/models/player.dart';

class Setup extends StatefulWidget {
  @override
  SetupState createState() {
    return SetupState();
  }
}

class SetupState extends State<Setup> {
  Color _pickerColor = Color(0xff443a49);
  TextEditingController nameController = TextEditingController();
  bool _isAi = false;
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    List<Player> players = gameState.getPlayers();
    //gameState.addPlayer();
    //gameState.setPieceMode();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              gameState.startGame();
            },
            child: Text("Start"),
          ),
          new Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 30.0, 0, 0),
            child: Text("Add players"),
          ),
          Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Expanded(
              child: new Padding(
                padding: const EdgeInsets.fromLTRB(2.0, 0, 0, 0),
                child: TextField(
                  controller: nameController,
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
                  secondary: new Icon(Icons.android),
                  activeColor: Colors.red,
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
                      return AlertDialog(
                        title: Text('Select a color'),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: _pickerColor,
                            onColorChanged: changeColor,
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
                padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                child: RaisedButton(
                  onPressed: () {
                    gameState.addPlayer(
                        nameController.text, _pickerColor, _isAi);
                  },
                  child: Text("Add"),
                ),
              ))
            ],
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 15.0),
            child: players != null
                ? ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];

                      return Dismissible(
                        key: Key(player.id.toString()),
                        onDismissed: (direction) {
                          gameState.removePlayer(player);
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(player.name + " removed")));
                        },
                        background: Container(color: Colors.deepOrange.shade300),
                        child: ListTile(
                          title: Text(player.name),
                          leading: Icon(
                              player.isAi ? Icons.android : Icons.person,
                              color: player.color),
                        ),
                      );
                    },
                  )
                : Text("No players",
                    style:
                        TextStyle(fontSize: 16, height: 8, color: Colors.grey)),
          ))
        ],
      ),
    );
  }

  void changeColor(Color value) {
    setState(() => _pickerColor = value);
    Navigator.pop(context, null);
  }

  void _aiChanged(bool value) => setState(() => _isAi = value);
}

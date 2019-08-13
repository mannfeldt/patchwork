import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draggable Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int counter;

  @override
  void initState() {
    this.counter = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draggable Test'),
      ),
      body: Column(
        children: <Widget>[
          Draggable(
            child: Container(
              color: Colors.red,
              width: 100,
              height: 100,
              child: Text(counter.toString()),
            ),
            feedback: Container(
              color: Colors.red,
              width: 100,
              height: 100,
              child: Text(counter.toString()),
            ),
            childWhenDragging: Container(
              color: Colors.red,
              width: 100,
              height: 100,
              child: Text(counter.toString()),
            ),
          ),
          RaisedButton(
            onPressed: () {
              setState(() {
                counter += 1;
              });
            },
            child: Text("inceremtn"),
          )
        ],
      ),
    );
  }
}

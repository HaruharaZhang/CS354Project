import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => Home();
}

class Home extends State<HomePage> {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Home Page")),
        body: Column(children: const <Widget>[
          Text(
            "this is the main app page",
            style: TextStyle(fontSize: 20),
          )
        ]));
  }
}

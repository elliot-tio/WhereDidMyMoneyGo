import 'package:flutter/material.dart';
import 'home.dart';

void main() => runApp(WhereDidMyMoneyGo());

/// This Widget is the main application widget.
class WhereDidMyMoneyGo extends StatelessWidget {
  static const String _title = 'Where Did My Money Go';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green[400],
        accentColor: Colors.cyan[200],
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold,)
        ),
      ),
      home: Home(),
    );
  }
}
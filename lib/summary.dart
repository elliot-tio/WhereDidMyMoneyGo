import 'package:flutter/material.dart';
import 'helpers.dart';

class Summary extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text('Clear DB'),
      onPressed: () => Helpers.clearDb(),
    );
  }
}
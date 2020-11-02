import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'expense.dart';
import 'helpers.dart';
import 'dart:async';
//import 'monthly_expenses_chart.dart';

class SummaryPopup extends StatefulWidget {
  final String category;
  SummaryPopup({Key key, @required this.category}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SummaryPopupState();
}

class _SummaryPopupState extends State<SummaryPopup> {
  var _children = <Widget>[
    SizedBox(
      child: CircularProgressIndicator(),
      width: 60,
      height: 60,
    ),
    const Padding(
      padding: EdgeInsets.only(top: 16),
      child: Text('Loading...'),
    )
  ];
  Timer _timer;

  @override
  void initState() {
    _timer = Timer(new Duration(seconds: 1), () {
      setState(() {
        _children = <Widget>[
          new Text(
            "Nothing here!", 
            style: TextStyle(
              fontSize: 25, 
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primaryVariant
            ),
          ),
        ];
      });
    });
    super.initState();
  }

  Future<List<Expense>> expenses(category) async {
    final Database db = await Helpers.getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses', 
      columns: [
        "amount",
        "dateTime",
        "location",
        "description",
        
      ], 
      where: "category = ?",
      whereArgs: [category]);

    return List.generate(maps.length, (i) {
      return Expense(
        amount: maps[i]['amount'],
        dateTime: maps[i]['datetime'],
        location: maps[i]['location'],
        description: maps[i]['description']
      );
    });
  }

  Future<List<Expense>> getExpenses(category) async {
    return await expenses(category);
  }

  @override
  void dispose() {
    _timer.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //Expanded(
          //  child: MonthlyExpenses(),
          //),
          Expanded(
            child: new FutureBuilder(
              future: getExpenses(widget.category),
              builder: (BuildContext context, AsyncSnapshot<List<Expense>> snapshot) {
                if (snapshot.data == null || snapshot.data.isEmpty || !snapshot.hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _children
                    )
                  );
                } else {
                  List<Expense> expensesList = snapshot.data;
                  return new ListView.separated(
                    itemCount: expensesList.length + 1,
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                    itemBuilder: (BuildContext context, int index) {
                      if(index < expensesList.length) {
                        var datetime = DateFormat.yMMMEd().add_jms().format(new DateTime.fromMillisecondsSinceEpoch(expensesList[index].dateTime));
                        var location = expensesList[index].location;
                        var desc = expensesList[index].description;
                        var amount = expensesList[index].amount.toStringAsFixed(2);
                        return ListTile(
                          title: Text('$desc', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Location: $location\n$datetime'),
                          trailing: Text('\$$amount'),
                        );
                      } else {
                        var total = expensesList.map<double>((ex) => ex.amount).reduce((a, b) => a + b);
                        return ListTile(
                          title: Text('Total:'),
                          trailing: Text('\$$total')
                        );
                      }
                    }
                  );
                }
              }
            )
          ),
        ]
      ),
    );
  }
}
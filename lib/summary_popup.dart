import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'expense.dart';
import 'helpers.dart';
import 'dart:async';
import 'monthly_expenses_chart.dart';

class SummaryPopup extends StatefulWidget {
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

  Future<List<Expense>> expenses() async {
    final Database db = await Helpers.getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses', 
      columns: [
        "SUM(amount) AS sum",
        "category",
        "dateTime",
      ], 
      groupBy: "category");

    return List.generate(maps.length, (i) {
      return Expense(
        category: maps[i]['category'],
        amount: maps[i]['sum'],
        dateTime: maps[i]['datetime']
      );
    });
  }

  Future<List<Expense>> getExpenses() async {
    return await expenses();
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
          Expanded(
            child: MonthlyExpenses(),
          ),
          Expanded(
            child: new FutureBuilder(
              future: getExpenses(),
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
                    itemCount: expensesList.length,
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                    itemBuilder: (BuildContext context, int index) {
                      var category = expensesList[index].category;
                      var amount = expensesList[index].amount.toStringAsFixed(2);
                      return Card(
                        color: Colors.amber[400],
                        child: ListTile(
                          leading: const Icon(Icons.monetization_on, size: 48),
                          title: Text('Category: $category', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Total: \$$amount'),
                          trailing: const Icon(Icons.arrow_right, size: 48),
                          // onTap: move to summary tab
                        )
                      );
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
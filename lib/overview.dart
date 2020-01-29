import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'expense.dart';
import 'helpers.dart';

class Overview extends StatefulWidget {
  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
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
  var _childrenTotal = <Widget>[
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
            "No expenses yet!", 
            style: TextStyle(
              fontSize: 25, 
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primaryVariant
            ),
          ),
        ];
        _childrenTotal = <Widget>[
          new Text(
            "\$0", 
            style: TextStyle(
              fontSize: 25, 
              fontWeight: FontWeight.bold,
              color: Colors.black
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

  Future<List<double>> totalExpenses() async {
    final Database db = await Helpers.getDatabase();

    final List<Map<String, dynamic>> total = await db.query(
      'expenses',
      columns: ["SUM(amount) AS total"],
    );

    return List.generate(total.length, (i) {
      return total[i]['total'];
    });
  }

  Future<List<Expense>> getExpenses() async {
    return await expenses();
  }

  Future<List<double>> getTotalExpenses() async {
    return await totalExpenses();
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
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 30, 
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primaryVariant
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                Divider(
                  height: 25,
                  thickness: 2,
                  color: Colors.black26,
                ),
              ]
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  'Total Expenses',
                  style: TextStyle(
                    fontSize: 25, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                Container(height: 15),
                new FutureBuilder(
                  future: getTotalExpenses(),
                  builder: (BuildContext context, AsyncSnapshot<List<double>> snapshot) {
                    if (snapshot.data == null || snapshot.data.isEmpty || !snapshot.hasData) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: _childrenTotal
                        )
                      );
                    }
                    var total = snapshot.data[0] != null ? snapshot.data[0].toStringAsFixed(2) : 0;
                    return new Text(
                      '\$$total',
                      style: TextStyle(
                        fontSize: 25, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    );
                  },
                )
              ],
            ),
            Divider(
              height: 25,
              thickness: 2,
              color: Colors.black26,
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
          ],
        )
      )
    );
  }
}
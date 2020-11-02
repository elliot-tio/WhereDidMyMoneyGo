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

  Future<List<Expense>> expenses(String category) async {
    final Database db = await Helpers.getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses', 
      columns: [
        "id",
        "amount",
        "dateTime",
        "location",
        "description",
        
      ], 
      where: "category = ?",
      whereArgs: [category]);

    return List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'],
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

  Future<void> deleteExpense(int id) async {
    final Database db = await Helpers.getDatabase();

    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _timer = null;
    super.dispose();
  }

  List<Expense> expensesList = [];

  void showDelete(context, expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) => 
        AlertDialog(
          title: Text('Delete expense',
            style: TextStyle(
                fontSize: 25, 
                fontWeight: FontWeight.bold,
                color: Colors.red
            )
          ),
          content: SingleChildScrollView(
            child: Text('Are you sure you want to delete this expense?'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                deleteExpense(expense.id);
                expensesList.remove(expense);
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ]
        ),
      barrierDismissible: false
    );
  }

  void showPopup(context, expense) {
    showDialog(
      context: context, 
      builder: (BuildContext context) => AlertDialog(
        title: Text('Edit expense',
          style: TextStyle(
              fontSize: 25, 
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primaryVariant
          )
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('This is a demo alert dialog.'),
              Text('Would you like to approve of this message?')
            ]
          )
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Approve'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ), 
      barrierDismissible: false);
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
                        var id = expensesList[index].id;
                        var expense = expensesList[index];
                        return ListTile(
                          key: ObjectKey(expense),
                          title: Text('$desc', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Location: $location\n$datetime'),
                          trailing: Text('\$$amount'),
                          leading: IconButton(
                            icon: Icon(Icons.clear),
                            iconSize: 20,
                            onPressed: () {
                              showDelete(context, expense);
                            }
                          ),
                          onTap: () { showPopup(context, expense); },
                        );
                      } else {
                        var total = expensesList.map<double>((ex) => ex.amount).reduce((a, b) => a + b).toStringAsFixed(2);
                        return ListTile(
                          title: Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('* Tap the row of an expense you wish to edit!'),
                          trailing: Text('\$$total'),
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
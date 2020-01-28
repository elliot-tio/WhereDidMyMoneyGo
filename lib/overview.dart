import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'expense.dart';
import 'helpers.dart';

class Overview extends StatelessWidget {
  Future<List<Expense>> expenses() async {
    // Get a reference to the database.
    final Database db = await Helpers.getDatabase();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('expenses');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'],
        description: maps[i]['description'],
        location: maps[i]['location'],
        category: maps[i]['category'],
        amount: maps[i]['amount'],
        dateTime: maps[i]['dateTime']
      );
    });
  }

  Future<List<Expense>> getExpenses() async {
    return await expenses();
  }

  final sum = 10000;
  final List<int> categoriesSum = <int>[100, 200, 300, 400, 500, 600, 700, 100, 200, 300, 400, 500, 600, 700, 100, 200, 300, 400, 500, 600, 700];

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
                Text(
                  '\$$sum',
                  style: TextStyle(
                    fontSize: 25, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
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
                  if (snapshot.data == null || snapshot.data.isEmpty || !snapshot.hasData)
                    return new Center(
                      child: new Text(
                        "No expenses yet!", 
                        style: TextStyle(
                          fontSize: 25, 
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primaryVariant
                        ),
                      ),
                    );
                  List<Expense> expensesList = snapshot.data;
                  return new ListView.separated(
                    itemCount: expensesList.length,
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        color: Colors.amber[400],
                        child: ListTile(
                          leading: const Icon(Icons.monetization_on, size: 56),
                          title: Text('Category: ${expensesList[index].category}'),
                          subtitle: Text('Total: \$${categoriesSum[index]}')
                        )
                      );
                    }
                  );
                }
              )
            ),
          ],
        )
      )
    );
  }
}
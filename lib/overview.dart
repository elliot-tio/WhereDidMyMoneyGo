
import 'package:flutter/material.dart';

class Overview extends StatelessWidget {
  final sum = 10000;
  final List<String> categories = <String>['A', 'B', 'C', 'D', 'E', 'F', 'G'];
  final List<int> categoriesSum = <int>[100, 200, 300, 400, 500, 600, 700];

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
              child: ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (BuildContext context, int index) => const Divider(),
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Colors.amber[400],
                    child: ListTile(
                      leading: const Icon(Icons.monetization_on, size: 56),
                      title: Text('Category ${categories[index]}'),
                      subtitle: Text('Total: \$${categoriesSum[index]}')
                    )
                  );
                }
              ),
            ),
          ],
        )
      )
    );
  }
}
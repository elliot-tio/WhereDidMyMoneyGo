import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'expense.dart';
import 'helpers.dart';
import 'dart:async';
import 'package:flutter_masked_text/flutter_masked_text.dart';
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

  FocusNode focusOnError;

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

    focusOnError = FocusNode();
  }

  // TODO:: make order selectable by user, or add a filter function
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
        "category"
      ], 
      where: "category = ?",
      whereArgs: [category],
      orderBy: "dateTime");

    return List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'],
        amount: maps[i]['amount'],
        dateTime: maps[i]['datetime'],
        location: maps[i]['location'],
        description: maps[i]['description'],
        category: maps[i]['category']
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
    focusOnError.dispose();
    super.dispose();
  }

  List<Expense> expensesList = [];

  void showDelete(context, expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) => 
        AlertDialog(
          title: Text('Delete ' + expense.description,
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

  Future<void> updateExpense(Expense expense) async {
    // Get a reference to the database.
    final Database db = await Helpers.getDatabase();

// TODO:: read up on how to do update
    await db.update(
      'expenses',
      expense.toMap(),
      where: "id = ?",
      whereArgs: [expense.id]
    );
  }

  void showPopup(parentContext, expense) {
    final _formKey = GlobalKey<FormState>();
    // TODO:: add values to db
    final _dropdownValues = <String>[
      'Bills', 
      'Debt', 
      'Entertainment', 
      'Food', 
      'Gas', 
      'Groceries',
      'Investment',
      'Pets',
      'Rent/Mortgage Payment',
      'Other'
    ];
    var _selectedCategory = expense.category;
    DateTime _dateTime = DateTime.fromMillisecondsSinceEpoch(expense.dateTime);
    final moneyController = new MoneyMaskedTextController(initialValue: expense.amount, decimalSeparator: '.', thousandSeparator: ',', leftSymbol: '\$', rightSymbol: ' CAD');
    final descriptionController = TextEditingController(text: expense.description);
    final locationController = TextEditingController(text: expense.location);

    showDialog(
      context: parentContext, 
      builder: (BuildContext context) => AlertDialog(
        title: Text('Edit ' + expense.description,
          style: TextStyle(
              fontSize: 25, 
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primaryVariant
          )
        ),
        content: SingleChildScrollView(
          child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Categories'),
                        DropdownButton(
                          items: _dropdownValues.map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          hint: new Text('Select a Category'),
                          isExpanded: true,
                          value: _selectedCategory,
                        ),
                      ]
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Description'),
                        TextFormField(
                          focusNode: focusOnError,
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            hintText: 'Enter a Description',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Location'),
                        TextFormField(
                          controller: locationController,
                          decoration: const InputDecoration(
                            hintText: 'Enter a Location',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a location';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Amount'),
                        TextFormField(
                          controller: moneyController,
                          keyboardType: TextInputType.number,
                          validator: (_) {
                            if(moneyController.numberValue == 0) {
                              return 'Please enter an amount';
                            }
                            return null;
                          },
                          textAlign: TextAlign.end,
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    RaisedButton(
                      child: Text(DateFormat.yMMMEd().format(_dateTime)),
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: _dateTime,
                          firstDate: DateTime(2019),
                          lastDate: DateTime(2100),
                        ).then((date) {
                          setState(() {
                            _dateTime = date == null ? DateTime.now() : date;
                          });
                        });
                      },
                      color: Theme.of(context).colorScheme.primary,
                      textColor: Colors.white,
                    )
                  ],
                ),
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
            child: Text('Update'),
            onPressed: () async {
              // Validate will return true if the form is valid, or false if
              // the form is invalid.
              if (_formKey.currentState.validate()) {
                // Process data.
                await updateExpense(Expense(
                  id: expense.id,
                  description: descriptionController.text,
                  location: locationController.text,
                  category: _selectedCategory,
                  amount: moneyController.numberValue,
                  dateTime: _dateTime.millisecondsSinceEpoch,
                ));
                setState(() {});
                ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: Text('Success! Expense Updated!'), backgroundColor: Colors.lightGreen[300],));
                Navigator.of(context).pop();
              } else {
                FocusScope.of(context).requestFocus(focusOnError);
              }
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
                        var datetime = DateFormat.yMMMEd().format(new DateTime.fromMillisecondsSinceEpoch(expensesList[index].dateTime));
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
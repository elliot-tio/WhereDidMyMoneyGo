import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class Expense {
  final int id;
  final String description;
  final String location;
  final String category;
  final double amount;
  final int dateTime;

  Expense({this.id, this.description, this.location, this.category, this.amount, this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'location': location,
      'category': category,
      'amount': amount,
      'dateTime': dateTime,
    };
  }
}

class AddExpenseForm extends StatefulWidget {
  AddExpenseForm({Key key}) : super(key: key);

  @override
  _AddExpenseFormState createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final moneyController = new MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',', leftSymbol: '\$', rightSymbol: ' CAD');
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  var _selectedCategory = "Bills";

  FocusNode focusOnError;

  @override
  void initState() {
    super.initState();

    focusOnError = FocusNode();
  }

  getDatabase() async {
    final Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'where_did_my_money_go.db'),

      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT, location TEXT, category TEXT, amount REAL, datetime INTEGER)"
        );
      },
      version: 1
    );
    return database;
  }

  Future<void> insertExpense(Expense expense) async {
    // Get a reference to the database.
    final Database db = await getDatabase();

    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    moneyController.dispose();
    descriptionController.dispose();
    focusOnError.dispose();
    super.dispose();
  }

  DateTime _dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Categories'),
              DropdownButton(
                items: <String>['Bills', 'Entertainment', 'Food', 'Gas', 'Other'].map((String value) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  color: Colors.blueAccent,
                  textColor: Colors.white,
                  onPressed: () async {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formKey.currentState.validate()) {
                      // Process data.
                      await insertExpense(Expense(
                        description: descriptionController.text,
                        location: locationController.text,
                        category: _selectedCategory,
                        amount: moneyController.numberValue,
                        dateTime: _dateTime.millisecondsSinceEpoch,
                      ));
                    } else {
                      FocusScope.of(context).requestFocus(focusOnError);
                    }
                  },
                  child: Text('Add Expense'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
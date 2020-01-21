import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';


void main() => runApp(WhereDidMyMoneyGo());

/// This Widget is the main application widget.
class WhereDidMyMoneyGo extends StatelessWidget {
  static const String _title = 'Where Did My Money Go?';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          title: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        ),
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    Text(
      'Overview',
      style: optionStyle,
    ),
    Text(
      'Summary',
      style: optionStyle,
    ),
    Container(
      padding: const EdgeInsets.all(32),
      child: AddExpenseForm(),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Where Did My Money Go?'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outlined),
            title: Text('Overview'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            title: Text('Summary'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            title: Text('Add Expense'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black.withOpacity(0.38),
        backgroundColor: Theme.of(context).colorScheme.primaryVariant,
        onTap: _onItemTapped,
      ),
    );
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

  var _selectedCategory;

  DateTime _dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Description'),
              TextFormField(
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
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formKey.currentState.validate()) {
                      // Process data.
                      print(_formKey);
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
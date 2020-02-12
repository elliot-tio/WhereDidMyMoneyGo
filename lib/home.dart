import 'package:flutter/material.dart';
import 'add_expense_form.dart';
import 'overview.dart';
import 'summary.dart';
import 'helpers.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    Container(
      padding: const EdgeInsets.all(16),
      child: Overview(),
    ),
    Container(
      padding: const EdgeInsets.all(16),
      child: Summary(),
    ),
    Container(
      padding: const EdgeInsets.all(16),
      child: AddExpenseForm(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
      final pageController = new PageController(
        initialPage: _selectedIndex,
        keepPage: true
      );

      void _pageChange(int index) {
        setState(() {
          _selectedIndex = index;
        });
      }

      void _onItemTapped(int index) {
        setState(() {
          _selectedIndex = index;
          pageController.animateToPage(index, duration: Duration(milliseconds: 200), curve: Curves.ease);
        });
      }

      final pageView = new PageView(
        controller: pageController,
        onPageChanged: (index) {
          _pageChange(index);
        },
        children: _widgetOptions
      );
      
    return Scaffold(
      appBar: AppBar(
        title: const Text('Where Did My Money Go?'),
        leading: RaisedButton(
          child: Text('Clear DB'),
          onPressed: () => Helpers.clearDb(),
        ),
      ),
      body: pageView,
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
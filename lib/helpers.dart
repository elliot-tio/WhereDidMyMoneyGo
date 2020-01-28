import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Helpers {
  static getDatabase() async {
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
}
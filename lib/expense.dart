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
      'datetime': dateTime,
    };
  }
}
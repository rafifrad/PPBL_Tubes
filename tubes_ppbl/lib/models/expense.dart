class Expense {
  final int? id;
  final double amount;
  final String category;
  final String date; // ISO-8601 (yyyy-MM-dd)

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'category': category,
        'date': date,
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'] as int?,
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String,
        date: map['date'] as String,
      );
}


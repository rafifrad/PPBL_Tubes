class Bill {
  final int? id;
  final String name;
  final double amount;
  final String dueDate; // ISO-8601 (yyyy-MM-dd)

  Bill({
    this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'amount': amount,
        'dueDate': dueDate,
      };

  factory Bill.fromMap(Map<String, dynamic> map) => Bill(
        id: map['id'] as int?,
        name: map['name'] as String,
        amount: (map['amount'] as num).toDouble(),
        dueDate: map['dueDate'] as String,
      );
}


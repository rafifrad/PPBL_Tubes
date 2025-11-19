class FinanceNote {
  final int? id;
  final String note;
  final double amount;

  FinanceNote({
    this.id,
    required this.note,
    required this.amount,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'note': note,
        'amount': amount,
      };

  factory FinanceNote.fromMap(Map<String, dynamic> map) => FinanceNote(
        id: map['id'] as int?,
        note: map['note'] as String,
        amount: (map['amount'] as num).toDouble(),
      );
}


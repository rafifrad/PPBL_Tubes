class DailyNeed {
  int? id;
  String name;
  int quantity;

  DailyNeed({
    this.id,
    required this.name,
    required this.quantity,
  });

  factory DailyNeed.fromMap(Map<String, dynamic> map) => DailyNeed(
        id: map['id'] as int?,
        name: map['name'] as String,
        quantity: map['quantity'] as int,
      );

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'name': name,
      'quantity': quantity,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}


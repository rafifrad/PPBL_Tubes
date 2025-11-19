class Food {
  int? id;
  String name;
  int quantity;
  String purchaseDate;

  Food({
    this.id,
    required this.name,
    required this.quantity,
    required this.purchaseDate,
  });

  factory Food.fromMap(Map<String, dynamic> map) => Food(
        id: map['id'] as int?,
        name: map['name'] as String,
        quantity: map['quantity'] as int,
        purchaseDate: map['purchaseDate'] as String,
      );

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'name': name,
      'quantity': quantity,
      'purchaseDate': purchaseDate,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}


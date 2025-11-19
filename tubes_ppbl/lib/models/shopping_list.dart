class ShoppingList {
  int? id;
  String item;
  int quantity;

  ShoppingList({
    this.id,
    required this.item,
    required this.quantity,
  });

  factory ShoppingList.fromMap(Map<String, dynamic> map) => ShoppingList(
        id: map['id'] as int?,
        item: map['item'] as String,
        quantity: map['quantity'] as int,
      );

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'item': item,
      'quantity': quantity,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}


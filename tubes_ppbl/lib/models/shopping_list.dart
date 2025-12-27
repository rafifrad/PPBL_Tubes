// Model untuk Daftar Belanja
// Menyimpan daftar barang yang perlu dibeli

class ShoppingList {
  // Field/properti yang dimiliki setiap item belanja
  int? id;          // ID unik
  String item;      // Nama barang
  int quantity;     // Jumlah
  double price;     // Harga estimasi (baru)

  // Constructor
  ShoppingList({
    this.id,
    required this.item,
    required this.quantity,
    this.price = 0,
  });

  factory ShoppingList.fromMap(Map<String, dynamic> map) => ShoppingList(
        id: map['id'] as int?,
        item: map['item'] as String,
        quantity: map['quantity'] as int,
        price: (map['price'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'item': item,
      'quantity': quantity,
      'price': price,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}

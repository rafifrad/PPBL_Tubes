// Model untuk data Persediaan Makanan
// Model = cetakan/template untuk struktur data yang akan disimpan di database

class Food {
  // Field/properti yang dimiliki setiap makanan
  int? id;              // ID unik
  String name;          // Nama makanan
  int quantity;         // Jumlah/stok
  String purchaseDate;  // Tanggal beli
  double price;         // Harga beli (baru)

  // Constructor
  Food({
    this.id,
    required this.name,
    required this.quantity,
    required this.purchaseDate,
    this.price = 0,     // Default 0
  });

  factory Food.fromMap(Map<String, dynamic> map) => Food(
        id: map['id'] as int?,
        name: map['name'] as String,
        quantity: map['quantity'] as int,
        purchaseDate: map['purchaseDate'] as String,
        price: (map['price'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'name': name,
      'quantity': quantity,
      'purchaseDate': purchaseDate,
      'price': price,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}

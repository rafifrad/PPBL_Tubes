// Model untuk Kebutuhan Harian
// Menyimpan daftar kebutuhan sehari-hari yang perlu dipenuhi

class DailyNeed {
  // Field/properti yang dimiliki setiap kebutuhan harian
  int? id;          // ID unik
  String name;      // Nama kebutuhan
  int quantity;     // Jumlah yang dibutuhkan
  double price;     // Harga/estimasi biaya (baru)

  // Constructor
  DailyNeed({
    this.id,
    required this.name,
    required this.quantity,
    this.price = 0,
  });

  factory DailyNeed.fromMap(Map<String, dynamic> map) => DailyNeed(
        id: map['id'] as int?,
        name: map['name'] as String,
        quantity: map['quantity'] as int,
        price: (map['price'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'name': name,
      'quantity': quantity,
      'price': price,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}

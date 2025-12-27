// Model untuk data Laundry (Cucian)
// Menyimpan informasi tentang cucian yang perlu/sedang dicuci

class Laundry {
  // Field/properti yang dimiliki setiap data laundry
  int? id;          // ID unik
  String type;      // Jenis cucian
  int quantity;     // Jumlah
  String status;    // Status
  double price;     // Harga/biaya (baru)

  // Constructor
  Laundry({
    this.id,
    required this.type,
    required this.quantity,
    required this.status,
    this.price = 0,
  });

  factory Laundry.fromMap(Map<String, dynamic> map) => Laundry(
        id: map['id'] as int?,
        type: map['type'] as String,
        quantity: map['quantity'] as int,
        status: map['status'] as String,
        price: (map['price'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'type': type,
      'quantity': quantity,
      'status': status,
      'price': price,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}

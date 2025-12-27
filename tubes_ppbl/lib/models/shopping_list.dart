// Model untuk Daftar Belanja
// Menyimpan daftar barang yang perlu dibeli

class ShoppingList {
  // Field/properti yang dimiliki setiap item belanja
  int? id;          // ID unik (auto-generated oleh database)
  String item;      // Nama barang (contoh: "Beras", "Minyak Goreng")
  int quantity;     // Jumlah yang perlu dibeli (contoh: 5 kg)

  // Constructor - cara membuat object ShoppingList baru
  ShoppingList({
    this.id,                // ID opsional
    required this.item,     // Nama barang wajib diisi
    required this.quantity, // Jumlah wajib diisi
  });

  // Factory method untuk membuat object ShoppingList dari Map (data dari database)
  factory ShoppingList.fromMap(Map<String, dynamic> map) => ShoppingList(
        id: map['id'] as int?,            // Ambil ID
        item: map['item'] as String,      // Ambil nama barang
        quantity: map['quantity'] as int, // Ambil jumlah
      );

  // Method untuk mengubah object ShoppingList jadi Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'item': item,         // Masukkan nama barang
      'quantity': quantity, // Masukkan jumlah
    };
    
    // Kalau ID ada, masukkan juga
    if (id != null) data['id'] = id;
    
    return data;
  }
}

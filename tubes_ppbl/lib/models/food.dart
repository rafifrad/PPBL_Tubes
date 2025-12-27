// Model untuk data Persediaan Makanan
// Model = cetakan/template untuk struktur data yang akan disimpan di database

class Food {
  // Field/properti yang dimiliki setiap makanan
  int? id;              // ID unik (auto-generated oleh database, bisa null untuk data baru)
  String name;          // Nama makanan (contoh: "Mie Instan")
  int quantity;         // Jumlah/stok (contoh: 5)
  String purchaseDate;  // Tanggal beli (format: "2025-12-27")

  // Constructor - cara membuat object Food baru
  Food({
    this.id,                      // ID opsional (untuk data baru, biarkan null)
    required this.name,           // Nama wajib diisi
    required this.quantity,       // Jumlah wajib diisi
    required this.purchaseDate,   // Tanggal wajib diisi
  });

  // Factory method untuk membuat object Food dari Map (data dari database)
  // Digunakan saat mengambil data dari database
  factory Food.fromMap(Map<String, dynamic> map) => Food(
        id: map['id'] as int?,                    // Ambil ID dari map
        name: map['name'] as String,              // Ambil nama dari map
        quantity: map['quantity'] as int,         // Ambil jumlah dari map
        purchaseDate: map['purchaseDate'] as String,  // Ambil tanggal dari map
      );

  // Method untuk mengubah object Food jadi Map (untuk disimpan ke database)
  // Digunakan saat menyimpan atau update data ke database
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'name': name,               // Masukkan nama ke map
      'quantity': quantity,       // Masukkan jumlah ke map
      'purchaseDate': purchaseDate,  // Masukkan tanggal ke map
    };
    
    // Kalau ID ada (data lama yang di-update), masukkan juga ID-nya
    if (id != null) data['id'] = id;
    
    return data;
  }
}

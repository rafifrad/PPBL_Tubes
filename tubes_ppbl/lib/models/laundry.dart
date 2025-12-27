// Model untuk data Laundry (Cucian)
// Menyimpan informasi tentang cucian yang perlu/sedang dicuci

class Laundry {
  // Field/properti yang dimiliki setiap data laundry
  int? id;          // ID unik (auto-generated oleh database)
  String type;      // Jenis cucian (contoh: "Baju", "Celana", "Handuk")
  int quantity;     // Jumlah (contoh: 5 potong)
  String status;    // Status (contoh: "Belum Dicuci", "Sedang Dicuci", "Selesai")

  // Constructor - cara membuat object Laundry baru
  Laundry({
    this.id,                  // ID opsional
    required this.type,       // Jenis wajib diisi
    required this.quantity,   // Jumlah wajib diisi
    required this.status,     // Status wajib diisi
  });

  // Factory method untuk membuat object Laundry dari Map (data dari database)
  factory Laundry.fromMap(Map<String, dynamic> map) => Laundry(
        id: map['id'] as int?,            // Ambil ID
        type: map['type'] as String,      // Ambil jenis
        quantity: map['quantity'] as int, // Ambil jumlah
        status: map['status'] as String,  // Ambil status
      );

  // Method untuk mengubah object Laundry jadi Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'type': type,         // Masukkan jenis
      'quantity': quantity, // Masukkan jumlah
      'status': status,     // Masukkan status
    };
    
    // Kalau ID ada, masukkan juga
    if (id != null) data['id'] = id;
    
    return data;
  }
}

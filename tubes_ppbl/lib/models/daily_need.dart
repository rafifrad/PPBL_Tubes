// Model untuk Kebutuhan Harian
// Menyimpan daftar kebutuhan sehari-hari yang perlu dipenuhi

class DailyNeed {
  // Field/properti yang dimiliki setiap kebutuhan harian
  int? id;          // ID unik (auto-generated oleh database)
  String name;      // Nama kebutuhan (contoh: "Sabun", "Shampo", "Pasta Gigi")
  int quantity;     // Jumlah yang dibutuhkan (contoh: 2 buah)

  // Constructor - cara membuat object DailyNeed baru
  DailyNeed({
    this.id,                // ID opsional
    required this.name,     // Nama wajib diisi
    required this.quantity, // Jumlah wajib diisi
  });

  // Factory method untuk membuat object DailyNeed dari Map (data dari database)
  factory DailyNeed.fromMap(Map<String, dynamic> map) => DailyNeed(
        id: map['id'] as int?,            // Ambil ID
        name: map['name'] as String,      // Ambil nama
        quantity: map['quantity'] as int, // Ambil jumlah
      );

  // Method untuk mengubah object DailyNeed jadi Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'name': name,         // Masukkan nama
      'quantity': quantity, // Masukkan jumlah
    };
    
    // Kalau ID ada, masukkan juga
    if (id != null) data['id'] = id;
    
    return data;
  }
}

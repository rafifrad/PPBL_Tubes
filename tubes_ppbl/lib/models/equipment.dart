// Model untuk data Peralatan Kamar
// Menyimpan informasi tentang barang-barang yang ada di kamar kost

class Equipment {
  // Field/properti yang dimiliki setiap peralatan
  int? id;            // ID unik (auto-generated oleh database)
  String name;        // Nama peralatan (contoh: "Kasur", "Meja Belajar")
  String condition;   // Kondisi barang (contoh: "Baik", "Rusak", "Perlu Perbaikan")

  // Constructor - cara membuat object Equipment baru
  Equipment({
    this.id,                  // ID opsional
    required this.name,       // Nama wajib diisi
    required this.condition,  // Kondisi wajib diisi
  });

  // Factory method untuk membuat object Equipment dari Map (data dari database)
  factory Equipment.fromMap(Map<String, dynamic> map) => Equipment(
        id: map['id'] as int?,              // Ambil ID
        name: map['name'] as String,        // Ambil nama
        condition: map['condition'] as String,  // Ambil kondisi
      );

  // Method untuk mengubah object Equipment jadi Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'name': name,           // Masukkan nama
      'condition': condition, // Masukkan kondisi
    };
    
    // Kalau ID ada, masukkan juga
    if (id != null) data['id'] = id;
    
    return data;
  }
}

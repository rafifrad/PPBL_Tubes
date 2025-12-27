// Model untuk data Pemasukan
// Menyimpan informasi tentang pemasukan (uang masuk)

class Income {
  // Field/properti yang dimiliki setiap pemasukan
  final int? id;              // ID unik (auto-generated oleh database)
  final double amount;        // Nominal pemasukan (contoh: 2000000.0)
  final String category;      // Kategori (contoh: "Gaji", "Uang Bulanan", "Freelance")
  final String description;   // Deskripsi detail (contoh: "Gaji bulan Desember")
  final String date;          // Tanggal pemasukan (format ISO-8601: "2025-12-27")

  // Constructor - cara membuat object Income baru
  Income({
    this.id,                      // ID opsional
    required this.amount,         // Nominal wajib diisi
    required this.category,       // Kategori wajib diisi
    this.description = '',        // Deskripsi opsional (default: string kosong)
    required this.date,           // Tanggal wajib diisi
  });

  // Method untuk mengubah object Income jadi Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() => {
        'id': id,                   // Masukkan ID
        'amount': amount,           // Masukkan nominal
        'category': category,       // Masukkan kategori
        'description': description, // Masukkan deskripsi
        'date': date,               // Masukkan tanggal
      };

  // Factory method untuk membuat object Income dari Map (data dari database)
  factory Income.fromMap(Map<String, dynamic> map) => Income(
        id: map['id'] as int?,                      // Ambil ID
        amount: (map['amount'] as num).toDouble(),  // Ambil nominal (convert ke double)
        category: map['category'] as String,        // Ambil kategori
        description: map['description'] as String? ?? '',  // Ambil deskripsi (default: '')
        date: map['date'] as String,                // Ambil tanggal
      );
}

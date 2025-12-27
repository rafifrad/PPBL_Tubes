// Model untuk data Tagihan Bulanan
// Menyimpan informasi tentang tagihan yang harus dibayar setiap bulan

class Bill {
  // Field/properti yang dimiliki setiap tagihan
  final int? id;        // ID unik (auto-generated oleh database)
  final String name;    // Nama tagihan (contoh: "Listrik", "Air", "WiFi")
  final double amount;  // Nominal tagihan (contoh: 100000.0)
  final String dueDate; // Tanggal jatuh tempo (format ISO-8601: "2025-12-31")

  // Constructor - cara membuat object Bill baru
  Bill({
    this.id,                  // ID opsional
    required this.name,       // Nama wajib diisi
    required this.amount,     // Nominal wajib diisi
    required this.dueDate,    // Tanggal jatuh tempo wajib diisi
  });

  // Method untuk mengubah object Bill jadi Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() => {
        'id': id,             // Masukkan ID
        'name': name,         // Masukkan nama
        'amount': amount,     // Masukkan nominal
        'dueDate': dueDate,   // Masukkan tanggal jatuh tempo
      };

  // Factory method untuk membuat object Bill dari Map (data dari database)
  factory Bill.fromMap(Map<String, dynamic> map) => Bill(
        id: map['id'] as int?,                      // Ambil ID
        name: map['name'] as String,                // Ambil nama
        amount: (map['amount'] as num).toDouble(),  // Ambil nominal (convert ke double)
        dueDate: map['dueDate'] as String,          // Ambil tanggal jatuh tempo
      );
}

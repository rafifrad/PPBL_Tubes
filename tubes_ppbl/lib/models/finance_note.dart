// Model untuk Catatan Keuangan (Banking Style)
// Menyimpan semua transaksi keuangan (pemasukan & pengeluaran) dengan tracking otomatis

class FinanceNote {
  // Field/properti yang dimiliki setiap transaksi keuangan
  final int? id;              // ID unik (auto-generated oleh database)
  final String note;          // Catatan/keterangan (contoh: "Uang bulanan dari ortu", "Makan siang")
  final double amount;        // Nominal transaksi (selalu positif, tipe menentukan +/-)
  final String type;          // Tipe transaksi: 'income' (pemasukan) atau 'expense' (pengeluaran)
  final DateTime timestamp;   // Waktu transaksi (untuk sorting dan grouping)
  final String source;        // Sumber transaksi (manual, makanan, tagihan, belanja, dll)

  // Constructor - cara membuat object FinanceNote baru
  FinanceNote({
    this.id,                    // ID opsional (null untuk data baru)
    required this.note,         // Catatan wajib diisi
    required this.amount,       // Nominal wajib diisi
    required this.type,         // Tipe wajib diisi ('income' atau 'expense')
    DateTime? timestamp,        // Timestamp opsional (default: sekarang)
    this.source = 'manual',     // Source opsional (default: 'manual')
  }) : timestamp = timestamp ?? DateTime.now(); // Kalau timestamp null, pakai waktu sekarang

  // Getter untuk cek apakah ini transaksi pemasukan
  // Contoh penggunaan: if (transaction.isIncome) { ... }
  bool get isIncome => type == 'income';

  // Getter untuk cek apakah ini transaksi pengeluaran
  // Contoh penggunaan: if (transaction.isExpense) { ... }
  bool get isExpense => type == 'expense';

  // Getter untuk mendapatkan nominal dengan tanda (+ atau -)
  // Pemasukan: +50000, Pengeluaran: -25000
  double get signedAmount => isIncome ? amount : -amount;

  // Method untuk mengubah object FinanceNote jadi Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() => {
        'id': id,                                    // Masukkan ID
        'note': note,                                // Masukkan catatan
        'amount': amount,                            // Masukkan nominal
        'type': type,                                // Masukkan tipe (income/expense)
        'timestamp': timestamp.millisecondsSinceEpoch, // Convert DateTime ke Unix timestamp (integer)
        'source': source,                            // Masukkan sumber transaksi
      };

  // Factory method untuk membuat object FinanceNote dari Map (data dari database)
  factory FinanceNote.fromMap(Map<String, dynamic> map) => FinanceNote(
        id: map['id'] as int?,                       // Ambil ID
        note: map['note'] as String,                 // Ambil catatan
        amount: (map['amount'] as num).toDouble(),   // Ambil nominal (convert ke double)
        type: map['type'] as String,                 // Ambil tipe
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int), // Convert Unix timestamp ke DateTime
        source: map['source'] as String? ?? 'manual', // Ambil source (default: 'manual' jika null)
      );
}

// Model untuk Catatan Keuangan
// Menyimpan catatan keuangan sederhana (pemasukan/pengeluaran dengan note)

class FinanceNote {
  // Field/properti yang dimiliki setiap catatan keuangan
  final int? id;        // ID unik (auto-generated oleh database)
  final String note;    // Catatan/keterangan (contoh: "Uang bulanan dari ortu")
  final double amount;  // Nominal (bisa positif untuk pemasukan, negatif untuk pengeluaran)

  // Constructor - cara membuat object FinanceNote baru
  FinanceNote({
    this.id,                // ID opsional
    required this.note,     // Catatan wajib diisi
    required this.amount,   // Nominal wajib diisi
  });

  // Method untuk mengubah object FinanceNote jadi Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() => {
        'id': id,           // Masukkan ID
        'note': note,       // Masukkan catatan
        'amount': amount,   // Masukkan nominal
      };

  // Factory method untuk membuat object FinanceNote dari Map (data dari database)
  factory FinanceNote.fromMap(Map<String, dynamic> map) => FinanceNote(
        id: map['id'] as int?,                      // Ambil ID
        note: map['note'] as String,                // Ambil catatan
        amount: (map['amount'] as num).toDouble(),  // Ambil nominal (convert ke double)
      );
}

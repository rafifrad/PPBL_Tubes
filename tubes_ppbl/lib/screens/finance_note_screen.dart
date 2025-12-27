// Import package Flutter untuk UI
import 'package:flutter/material.dart';
import 'dart:async'; // Untuk StreamSubscription
import 'package:intl/intl.dart'; // Untuk format tanggal & mata uang
// Import database helper untuk akses database
import '../database/database_helper.dart';
// Import model FinanceNote (cetakan data catatan keuangan)
import '../models/finance_note.dart';

// Halaman Catatan Keuangan - Versi Perbankan (Banking Style)
class FinanceNoteScreen extends StatefulWidget {
  const FinanceNoteScreen({super.key});

  @override
  State<FinanceNoteScreen> createState() => _FinanceNoteScreenState();
}

class _FinanceNoteScreenState extends State<FinanceNoteScreen> {
  // Instance database helper
  final _db = DatabaseHelper.instance;
  
  // Variabel untuk menyimpan data
  List<FinanceNote> _notes = [];
  double _balance = 0;
  bool _loading = true;
  
  // Subscription untuk mendengarkan perubahan transaksi
  StreamSubscription? _transactionSub;

  @override
  void initState() {
    super.initState();
    _refreshData(); // Ambil data saat pertama kali buka
    
    // OTOMATIS: Dapatkan data terbaru jika ada transaksi di halaman lain
    _transactionSub = _db.onTransactionChanged.listen((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _transactionSub?.cancel(); // Bersihkan subscription
    super.dispose();
  }

  // Fungsi untuk mengambil data terbaru (catatan & saldo)
  Future<void> _refreshData() async {
    setState(() => _loading = true);
    
    // Ambil saldo dan daftar transaksi secara paralel
    final results = await Future.wait([
      _db.getCurrentBalance(),
      _db.getAllFinanceNotes(),
    ]);
    
    setState(() {
      _balance = results[0] as double;
      _notes = results[1] as List<FinanceNote>;
      _loading = false;
    });
  }

  // Fungsi untuk menampilkan dialog "Tambah Saldo" (Pemasukan Manual)
  Future<void> _showAddBalanceDialog() async {
    final noteCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Saldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Input Nominal
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Nominal Pemasukan',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            // Input Catatan
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Keterangan (Opsional)',
                hintText: 'Contoh: Kiriman Orang Tua',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (amountCtrl.text.isEmpty) return;

              final note = FinanceNote(
                note: noteCtrl.text.isEmpty ? 'Tambah Saldo Manual' : noteCtrl.text,
                amount: double.tryParse(amountCtrl.text) ?? 0,
                type: 'income',
                source: 'manual',
              );

              await _db.insertFinanceNote(note);
              if (!mounted) return;
              Navigator.pop(context);
              _refreshData(); // Refresh tampilan
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menghapus transaksi
  Future<void> _deleteNote(FinanceNote note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Menghapus transaksi akan mengupdate saldo Anda kembali. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deleteFinanceNote(note.id!);
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- HEADER SALDO (STYLE BANKING) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.indigo[600],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Saldo Saat Ini',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(_balance)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tombol Tambah Saldo
                      ElevatedButton.icon(
                        onPressed: _showAddBalanceDialog,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Tambah Saldo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.indigo[600],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- DAFTAR TRANSAKSI (TIMELINE) ---
                Expanded(
                  child: _notes.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            final note = _notes[index];
                            final isIncome = note.isIncome;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.grey[200]!),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                visualDensity: VisualDensity.compact,
                                // Icon berdasarkan source
                                leading: CircleAvatar(
                                  backgroundColor: isIncome ? Colors.green[50] : Colors.red[50],
                                  child: Icon(
                                    _getIconData(note.source),
                                    color: isIncome ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                                ),
                                // Catatan & Info Source
                                title: Text(
                                  note.note,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${DateFormat('dd MMM, HH:mm').format(note.timestamp)} • ${note.source.toUpperCase()}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                // Nominal (+ / -)
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${isIncome ? '+' : '-'} Rp ${NumberFormat('#,###', 'id_ID').format(note.amount)}',
                                      style: TextStyle(
                                        color: isIncome ? Colors.green[700] : Colors.red[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                                      onPressed: () => _deleteNote(note),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // Helper untuk mendapatkan icon berdasarkan sumber transaksi
  IconData _getIconData(String source) {
    switch (source.toLowerCase()) {
      case 'makanan': return Icons.fastfood;
      case 'tagihan': return Icons.receipt_long;
      case 'laundry': return Icons.local_laundry_service;
      case 'belanja': return Icons.shopping_cart;
      case 'pengeluaran_kos': return Icons.payments;
      case 'kebutuhan_harian': return Icons.check_circle;
      default: return Icons.account_balance_wallet;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat transaksi',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

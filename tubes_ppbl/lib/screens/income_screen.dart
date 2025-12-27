// Import package Flutter untuk UI
import 'package:flutter/material.dart';
// Import database helper untuk akses database
import '../database/database_helper.dart';
// Import model Income (cetakan data pemasukan)
import '../models/income.dart';

// Halaman Pemasukan - Mengelola tracking pemasukan (uang masuk)
class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  // Instance database helper
  final _db = DatabaseHelper.instance;
  
  // List untuk menyimpan semua data pemasukan
  List<Income> _incomes = [];
  
  // Status loading
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadIncomes();  // Load data saat pertama kali buka halaman
  }

  // Fungsi untuk mengambil semua data pemasukan dari database
  Future<void> _loadIncomes() async {
    setState(() => _loading = true);  // Tampilkan loading
    
    final data = await _db.getAllIncomes();  // Ambil data dari database
    
    setState(() {
      _incomes = data;     // Simpan data ke variable
      _loading = false;    // Matikan loading
    });
  }

  // Fungsi untuk mengelompokkan pemasukan berdasarkan tanggal
  // Hasilnya: {"2025-12-27": [income1, income2], "2025-12-26": [income3]}
  Map<String, List<Income>> _groupByDate() {
    Map<String, List<Income>> grouped = {};
    
    for (var income in _incomes) {
      String date = income.date;  // Ambil tanggal
      
      // Kalau tanggal belum ada di map, buat list baru
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      
      // Tambahkan income ke list tanggal tersebut
      grouped[date]!.add(income);
    }
    
    return grouped;
  }

  // Fungsi untuk format tanggal jadi "Hari Ini", "Kemarin", atau tanggal lengkap
  String _formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);  // Parse string jadi DateTime
    DateTime now = DateTime.now();  // Tanggal hari ini
    
    // Hitung selisih hari
    int difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hari Ini';
    } else if (difference == 1) {
      return 'Kemarin';
    } else {
      // Format: "27 Desember 2025"
      List<String> months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  // Fungsi untuk format angka jadi format rupiah (contoh: 2000000 -> 2.000.000)
  String _formatRupiah(double amount) {
    String str = amount.toInt().toString();
    String result = '';
    int count = 0;
    
    // Loop dari belakang, tambahkan titik setiap 3 digit
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result';
        count = 0;
      }
      result = str[i] + result;
      count++;
    }
    
    return result;
  }

  // Fungsi untuk menampilkan dialog tambah/edit pemasukan
  Future<void> _showIncomeDialog({Income? income}) async {
    // Controller untuk input field
    final nominalCtrl = TextEditingController(
      text: income?.amount.toString() ?? '',
    );
    final categoryCtrl = TextEditingController(
      text: income?.category ?? '',
    );
    final descriptionCtrl = TextEditingController(
      text: income?.description ?? '',
    );
    
    // Tanggal yang dipilih (default: hari ini atau tanggal dari income)
    DateTime selectedDate = income != null 
        ? DateTime.parse(income.date) 
        : DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              // Judul dialog (Tambah atau Edit)
              title: Text(income == null ? 'Tambah Pemasukan' : 'Edit Pemasukan'),
              
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Input Nominal
                    TextField(
                      controller: nominalCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nominal',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,  // Keyboard angka
                    ),
                    const SizedBox(height: 12),
                    
                    // Input Kategori
                    TextField(
                      controller: categoryCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        hintText: 'Contoh: Gaji, Uang Bulanan, Freelance',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Input Deskripsi (opsional)
                    TextField(
                      controller: descriptionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi (opsional)',
                        hintText: 'Contoh: Gaji bulan Desember',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    
                    // Pilih Tanggal
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Tanggal'),
                      subtitle: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        // Tampilkan date picker
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        
                        if (picked != null) {
                          setStateDialog(() => selectedDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              actions: [
                // Tombol Batal
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                
                // Tombol Simpan
                ElevatedButton(
                  onPressed: () async {
                    // Validasi: nominal dan kategori harus diisi
                    if (nominalCtrl.text.isEmpty || categoryCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nominal dan kategori harus diisi')),
                      );
                      return;
                    }

                    // Buat object Income baru
                    final incomeData = Income(
                      id: income?.id,
                      amount: double.tryParse(nominalCtrl.text) ?? 0,
                      category: categoryCtrl.text.trim(),
                      description: descriptionCtrl.text.trim(),
                      date: selectedDate.toIso8601String().split('T').first,
                    );

                    // Simpan ke database
                    if (income == null) {
                      await _db.insertIncome(incomeData);  // Tambah baru
                    } else {
                      await _db.updateIncome(incomeData);  // Update yang lama
                    }

                    if (!mounted) return;
                    Navigator.pop(context);  // Tutup dialog
                    _loadIncomes();  // Refresh data
                    
                    // Tampilkan notifikasi sukses
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          income == null ? 'Pemasukan ditambahkan' : 'Pemasukan diperbarui',
                        ),
                      ),
                    );
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Fungsi untuk hapus pemasukan
  Future<void> _deleteIncome(Income income) async {
    // Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pemasukan'),
        content: Text('Yakin hapus pemasukan ${income.category}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    // Kalau user klik "Hapus"
    if (confirm == true) {
      await _db.deleteIncome(income.id!);  // Hapus dari database
      _loadIncomes();  // Refresh data
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pemasukan dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kalau masih loading, tampilkan loading indicator
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Kalau data kosong, tampilkan pesan kosong
    if (_incomes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Belum ada catatan pemasukan',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Kelompokkan data berdasarkan tanggal
    final groupedIncomes = _groupByDate();
    
    // Urutkan tanggal dari terbaru ke terlama
    final sortedDates = groupedIncomes.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Tampilkan list
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          String date = sortedDates[index];
          List<Income> incomes = groupedIncomes[date]!;
          
          // Hitung total pemasukan untuk tanggal ini
          double total = 0;
          for (var income in incomes) {
            total += income.amount;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER TANGGAL
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.green[50],  // Warna hijau untuk income
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tanggal (Hari Ini, Kemarin, dll)
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Total pemasukan hari ini
                    Text(
                      'Total: Rp ${_formatRupiah(total)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,  // Hijau untuk income
                      ),
                    ),
                  ],
                ),
              ),

              // LIST PEMASUKAN
              ...incomes.map((income) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    // Icon di kiri (hijau untuk income)
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: const Icon(Icons.account_balance_wallet, color: Colors.green),
                    ),
                    
                    // Konten utama
                    title: Text(
                      income.category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    
                    // Deskripsi (kalau ada)
                    subtitle: income.description.isNotEmpty
                        ? Text(income.description)
                        : null,
                    
                    // Nominal di kanan
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tampilkan nominal (hijau untuk income)
                        Text(
                          '+Rp ${_formatRupiah(income.amount)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,  // Hijau untuk income
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Tombol Edit
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                          onPressed: () => _showIncomeDialog(income: income),
                        ),
                        
                        // Tombol Hapus
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _deleteIncome(income),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              
              const SizedBox(height: 8),
            ],
          );
        },
      ),
      
      // Tombol tambah di kanan bawah (hijau untuk income)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showIncomeDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

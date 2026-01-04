import 'dart:async'; // Untuk StreamSubscription
import 'package:flutter/material.dart';
import '../database/database_helper.dart'; // Import DatabaseHelper
// Import service untuk menyimpan preferensi user (nama)
import '../services/preferences_service.dart';
// Import widgets untuk chart dan summary
import '../widgets/weekly_expense_chart.dart';
import '../widgets/expense_summary_cards.dart';

// Halaman Home - Halaman utama/dashboard aplikasi
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Service untuk menyimpan data preferensi (SharedPreferences)
  final _prefs = PreferencesService.instance;

  // Variable untuk menyimpan status dan data
  bool _loading = true;              // Status loading
  String _name = 'Pengguna';         // Nama user (default: "Pengguna")
  final _nameCtrl = TextEditingController();  // Controller untuk input nama

  // Subscription untuk mendengarkan perubahan transaksi
  StreamSubscription? _transactionSubscription;

  @override
  void initState() {
    super.initState();
    _load();  // Load data saat pertama kali buka halaman
    
    // Dengarkan perubahan database
    _transactionSubscription = DatabaseHelper.instance.onTransactionChanged.listen((_) {
      if (mounted) {
        _load(); // Reload data jika ada perubahan
        setState(() {}); // Trigger rebuild
      }
    });
  }

  // Fungsi untuk load nama user dari SharedPreferences
  Future<void> _load() async {
    await _prefs.init();  // Inisialisasi SharedPreferences
    
    setState(() {
      // Ambil nama dari SharedPreferences, kalau kosong pakai "Pengguna"
      _name = _prefs.getUserName() ?? 'Pengguna';
      _nameCtrl.text = _name;  // Set text di input field
      _loading = false;        // Matikan loading
    });
  }

  // Fungsi untuk menampilkan dialog edit nama
  Future<void> _showEditNameDialog() async {
    final tempCtrl = TextEditingController(text: _name);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ganti Nama'),
        content: TextField(
          controller: tempCtrl,
          decoration: const InputDecoration(
            labelText: 'Nama Anda',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = tempCtrl.text.trim();
              if (text.isEmpty) return;
              
              await _prefs.saveUserName(text);
              setState(() => _name = text);
              
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nama tersimpan')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    
    tempCtrl.dispose();
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel(); // Hapus listener saat halaman ditutup
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kalau masih loading, tampilkan loading indicator
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      // AppBar dengan nama user dan tombol edit
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.home, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Halo, $_name',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditNameDialog,
            tooltip: 'Ganti Nama',
          ),
        ],
        elevation: 0,
      ),

      // Body dengan RefreshIndicator
      body: RefreshIndicator(
        onRefresh: () async {
          await _load();
          // Trigger rebuild untuk refresh chart
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              const ExpenseSummaryCards(),
              const SizedBox(height: 20),

              // Weekly Chart
              const WeeklyExpenseChart(),
              const SizedBox(height: 20),

              // Quick Info
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fitur Aplikasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Kelola Keuangan',
                        subtitle: 'Catat pengeluaran & kebutuhan harian',
                        color: Colors.blue,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        icon: Icons.fastfood_outlined,
                        title: 'Persediaan Makanan',
                        subtitle: 'Pantau stok makanan di kost',
                        color: Colors.orange,
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        icon: Icons.shopping_cart_outlined,
                        title: 'Daftar Belanja',
                        subtitle: 'Buat daftar belanjaan',
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Tips Card
              Card(
                elevation: 1,
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tarik ke bawah untuk refresh data terbaru',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

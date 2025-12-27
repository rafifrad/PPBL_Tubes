// Import package Flutter untuk UI
import 'package:flutter/material.dart';
// Import service untuk menyimpan preferensi user (nama)
import '../services/preferences_service.dart';

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

  @override
  void initState() {
    super.initState();
    _load();  // Load data saat pertama kali buka halaman
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

  // Fungsi untuk menyimpan nama user
  Future<void> _saveName() async {
    final text = _nameCtrl.text.trim();  // Ambil text dari input, hapus spasi
    
    // Kalau kosong, jangan simpan
    if (text.isEmpty) return;
    
    // Simpan nama ke SharedPreferences
    await _prefs.saveUserName(text);
    
    // Update tampilan
    setState(() => _name = text);
    
    // Tampilkan notifikasi sukses
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nama tersimpan')),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();  // Hapus controller saat halaman ditutup (hindari memory leak)
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
      // RefreshIndicator - bisa pull down untuk refresh
      body: RefreshIndicator(
        onRefresh: _load,  // Fungsi yang dipanggil saat pull down
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sapaan dengan nama user
              Text(
                'Halo, $_name',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Instruksi
              const Text('Masukkan nama Anda untuk disimpan:'),
              const SizedBox(height: 12),
              
              // Input nama + tombol simpan
              Row(
                children: [
                  // Input field
                  Expanded(
                    child: TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan nama Anda',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Tombol simpan
                  ElevatedButton.icon(
                    onPressed: _saveName,
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
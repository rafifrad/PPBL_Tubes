import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../services/preferences_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper.instance;
  final _prefs = PreferencesService.instance;

  bool _loading = true;
  String _name = 'Pengguna';
  int _food = 0;
  int _equipment = 0;
  int _laundry = 0;
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _prefs.init();
    final foods = await _db.getAllFoods();
    final equipments = await _db.getAllEquipments();
    final laundries = await _db.getAllLaundries();
    setState(() {
      _name = _prefs.getUserName() ?? 'Pengguna';
      _nameCtrl.text = _name;
      _food = foods.length;
      _equipment = equipments.length;
      _laundry = laundries.length;
      _loading = false;
    });
  }

  Future<void> _saveName() async {
    final text = _nameCtrl.text.trim();
    if (text.isEmpty) return;
    await _prefs.saveUserName(text);
    setState(() => _name = text);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nama tersimpan')));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $_name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Berikut ringkasan data yang tersimpan:'),
                const SizedBox(height: 12),
                Text('• Persediaan makanan: $_food item'),
                Text('• Peralatan kamar: $_equipment item'),
                Text('• Laundry: $_laundry item'),
                const Divider(height: 32),
                const Text(
                  'Nama Penghuni',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nama Anda',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
          const SizedBox(height: 24),
          const Text(
            'Akses cepat:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/food'),
            child: const Text('Kelola Persediaan Makanan'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/equipment'),
            child: const Text('Kelola Peralatan Kamar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/laundry'),
            child: const Text('Kelola Laundry'),
          ),
        ],
      ),
    );
  }
}

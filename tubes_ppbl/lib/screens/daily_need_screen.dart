import 'package:flutter/material.dart';
import '../models/daily_need.dart';
import '../database/database_helper.dart';

class DailyNeedScreen extends StatefulWidget {
  const DailyNeedScreen({super.key});

  @override
  State<DailyNeedScreen> createState() => _DailyNeedScreenState();
}

class _DailyNeedScreenState extends State<DailyNeedScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<DailyNeed> _dailyNeeds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyNeeds();
  }

  Future<void> _loadDailyNeeds() async {
    setState(() => _isLoading = true);
    final dailyNeeds = await _dbHelper.getAllDailyNeeds();
    setState(() {
      _dailyNeeds = dailyNeeds;
      _isLoading = false;
    });
  }

  Future<void> _showAddEditDialog({DailyNeed? dailyNeed}) async {
    final nameController = TextEditingController(text: dailyNeed?.name ?? '');
    final quantityController = TextEditingController(
      text: dailyNeed?.quantity.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dailyNeed == null ? 'Tambah Kebutuhan Harian' : 'Edit Kebutuhan Harian'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kebutuhan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  quantityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Harap isi semua field'),
                  ),
                );
                return;
              }

              final dailyNeedToSave = DailyNeed(
                id: dailyNeed?.id,
                name: nameController.text,
                quantity: int.parse(quantityController.text),
              );

              if (dailyNeed == null) {
                await _dbHelper.insertDailyNeed(dailyNeedToSave);
              } else {
                await _dbHelper.updateDailyNeed(dailyNeedToSave);
              }

              if (mounted) {
                Navigator.pop(context);
                _loadDailyNeeds();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      dailyNeed == null
                          ? 'Kebutuhan harian ditambahkan'
                          : 'Kebutuhan harian diupdate',
                    ),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDailyNeed(DailyNeed dailyNeed) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kebutuhan Harian'),
        content: Text('Yakin hapus ${dailyNeed.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.deleteDailyNeed(dailyNeed.id!);
      _loadDailyNeeds();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kebutuhan harian dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dailyNeeds.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada kebutuhan harian',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _dailyNeeds.length,
                  itemBuilder: (context, index) {
                    final dailyNeed = _dailyNeeds[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange[100],
                          child: const Icon(Icons.check_circle, color: Colors.orange),
                        ),
                        title: Text(
                          dailyNeed.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Jumlah: ${dailyNeed.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddEditDialog(dailyNeed: dailyNeed),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteDailyNeed(dailyNeed),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}


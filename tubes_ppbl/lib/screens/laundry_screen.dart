import 'package:flutter/material.dart';
import '../models/laundry.dart';
import '../database/database_helper.dart';

class LaundryScreen extends StatefulWidget {
  const LaundryScreen({super.key});

  @override
  State<LaundryScreen> createState() => _LaundryScreenState();
}

class _LaundryScreenState extends State<LaundryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Laundry> _laundries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLaundries();
  }

  Future<void> _loadLaundries() async {
    setState(() => _isLoading = true);
    final laundries = await _dbHelper.getAllLaundries();
    setState(() {
      _laundries = laundries;
      _isLoading = false;
    });
  }

  Future<void> _showAddEditDialog({Laundry? laundry}) async {
    final typeController = TextEditingController(text: laundry?.type ?? '');
    final quantityController = TextEditingController(
      text: laundry?.quantity.toString() ?? '',
    );
    String selectedStatus = laundry?.status ?? 'Pending';

    final statuses = ['Pending', 'Sedang Dicuci', 'Selesai'];

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(
                    laundry == null ? 'Tambah Laundry' : 'Edit Laundry',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: typeController,
                          decoration: const InputDecoration(
                            labelText: 'Jenis Pakaian',
                            border: OutlineInputBorder(),
                            hintText: 'Contoh: Kaos, Celana, Dll',
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
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              statuses.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setDialogState(() => selectedStatus = value!);
                          },
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
                        if (typeController.text.isEmpty ||
                            quantityController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Harap isi semua field'),
                            ),
                          );
                          return;
                        }

                        final laundryToSave = Laundry(
                          id: laundry?.id,
                          type: typeController.text,
                          quantity: int.parse(quantityController.text),
                          status: selectedStatus,
                        );

                        if (laundry == null) {
                          await _dbHelper.insertLaundry(laundryToSave);
                        } else {
                          await _dbHelper.updateLaundry(laundryToSave);
                        }

                        if (mounted) {
                          Navigator.pop(context);
                          _loadLaundries();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                laundry == null
                                    ? 'Laundry ditambahkan'
                                    : 'Laundry diupdate',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _deleteLaundry(Laundry laundry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Laundry'),
            content: Text('Yakin hapus ${laundry.type}?'),
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
      await _dbHelper.deleteLaundry(laundry.id!);
      _loadLaundries();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Laundry dihapus')));
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Sedang Dicuci':
        return Colors.blue;
      case 'Selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _laundries.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_laundry_service,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada laundry',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _laundries.length,
                itemBuilder: (context, index) {
                  final laundry = _laundries[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple[100],
                        child: const Icon(
                          Icons.local_laundry_service,
                          color: Colors.purple,
                        ),
                      ),
                      title: Text(
                        laundry.type,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jumlah: ${laundry.quantity}'),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    laundry.status,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  laundry.status,
                                  style: TextStyle(
                                    color: _getStatusColor(laundry.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed:
                                () => _showAddEditDialog(laundry: laundry),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteLaundry(laundry),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

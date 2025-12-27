import 'package:flutter/material.dart';
// Import custom widgets
import '../widgets/widgets.dart';

/// Contoh Screen yang menggunakan Custom Widget
/// Screen ini mendemonstrasikan penggunaan semua custom widget yang sudah dibuat
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _hasData = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    setState(() => _isLoading = true);

    // Simulasi proses save (2 detik)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasData = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan!')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contoh Custom Widget')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== CONTOH MENU CARD =====
            const Text(
              '1. Menu Card',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                MenuCard(
                  title: 'Makanan',
                  subtitle: 'Kelola daftar makanan',
                  icon: Icons.restaurant,
                  iconColor: Colors.orange,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menu Makanan diklik')),
                    );
                  },
                ),
                MenuCard(
                  title: 'Peralatan',
                  subtitle: 'Kelola peralatan kost',
                  icon: Icons.kitchen,
                  iconColor: Colors.green,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menu Peralatan diklik')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // ===== CONTOH CUSTOM INPUT =====
            const Text(
              '2. Custom Input',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            CustomInput(
              label: 'Nama Lengkap',
              hint: 'Masukkan nama Anda',
              controller: _nameController,
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            CustomInput(
              label: 'Email',
              hint: 'contoh@email.com',
              controller: _emailController,
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            CustomInput(
              label: 'Catatan',
              hint: 'Tulis catatan di sini...',
              controller: _notesController,
              maxLines: 4,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // ===== CONTOH CUSTOM BUTTON =====
            const Text(
              '3. Custom Button',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Button normal
            CustomButton(
              text: 'Simpan Data',
              icon: Icons.save,
              onPressed: _isLoading ? null : _handleSave,
            ),

            const SizedBox(height: 12),

            // Button dengan loading
            CustomButton(text: 'Menyimpan...', isLoading: _isLoading),

            const SizedBox(height: 12),

            // Button dengan custom color
            CustomButton(
              text: 'Hapus Data',
              icon: Icons.delete,
              backgroundColor: Colors.red,
              onPressed: () {
                setState(() => _hasData = false);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Data dihapus')));
              },
            ),

            const SizedBox(height: 12),

            // Button dengan custom width
            CustomButton(text: 'Submit', width: 200, onPressed: () {}),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // ===== CONTOH CUSTOM CARD =====
            const Text(
              '4. Custom Card',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Informasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ini adalah contoh Custom Card yang dapat digunakan untuk menampilkan konten dalam card yang konsisten.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            CustomCard(
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Card diklik!')));
              },
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.touch_app, color: Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Clickable Card',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Tap card ini untuk melihat aksi',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // ===== CONTOH EMPTY STATE =====
            const Text(
              '5. Empty State',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  _hasData
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 64,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Ada Data!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                      : EmptyState(
                        icon: Icons.inbox_outlined,
                        title: 'Belum Ada Data',
                        message:
                            'Anda belum memiliki data.\nTambahkan data baru untuk memulai.',
                        actionText: 'Tambah Data',
                        onActionPressed: () {
                          setState(() => _hasData = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Data ditambahkan!')),
                          );
                        },
                      ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

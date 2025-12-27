// Import package Flutter untuk UI
import 'package:flutter/material.dart';
// Import database helper untuk akses database
import '../database/database_helper.dart';
// Import model FinanceNote (cetakan data catatan keuangan)
import '../models/finance_note.dart';
// Import custom widgets
import '../widgets/widgets.dart';

// Halaman Catatan Keuangan - Mengelola catatan keuangan sederhana
class FinanceNoteScreen extends StatefulWidget {
  const FinanceNoteScreen({super.key});

  @override
  State<FinanceNoteScreen> createState() => _FinanceNoteScreenState();
}

class _FinanceNoteScreenState extends State<FinanceNoteScreen> {
  // Instance database helper
  final _db = DatabaseHelper.instance;

  // List untuk menyimpan semua catatan keuangan
  List<FinanceNote> _notes = [];

  // Status loading
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes(); // Load data saat pertama kali buka halaman
  }

  // Fungsi untuk mengambil semua catatan keuangan dari database
  Future<void> _loadNotes() async {
    setState(() => _loading = true); // Tampilkan loading

    final data = await _db.getAllFinanceNotes(); // Ambil data dari database

    setState(() {
      _notes = data; // Simpan data ke variable
      _loading = false; // Matikan loading
    });
  }

  // Fungsi untuk menampilkan dialog tambah/edit catatan
  Future<void> _showNoteDialog({FinanceNote? note}) async {
    // Controller untuk input field
    final noteCtrl = TextEditingController(text: note?.note ?? '');
    final amountCtrl = TextEditingController(
      text: note?.amount.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            // Judul dialog (Tambah atau Edit)
            title: Text(note == null ? 'Tambah Catatan' : 'Edit Catatan'),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Input Catatan (multi-line)
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Catatan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2, // Bisa 2 baris
                ),
                const SizedBox(height: 12),

                // Input Nominal
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nominal',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number, // Keyboard angka
                ),
              ],
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
                  // Validasi: semua field harus diisi
                  if (noteCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Harap isi semua field')),
                    );
                    return;
                  }

                  // Buat object FinanceNote
                  final noteData = FinanceNote(
                    id: note?.id, // ID (null untuk data baru)
                    note: noteCtrl.text.trim(),
                    amount: double.tryParse(amountCtrl.text) ?? 0,
                  );

                  // Simpan ke database
                  if (note == null) {
                    await _db.insertFinanceNote(noteData); // Tambah baru
                  } else {
                    await _db.updateFinanceNote(noteData); // Update
                  }

                  if (!mounted) return;
                  Navigator.pop(context); // Tutup dialog
                  _loadNotes(); // Refresh data

                  // Tampilkan notifikasi sukses
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        note == null
                            ? 'Catatan ditambahkan'
                            : 'Catatan diperbarui',
                      ),
                    ),
                  );
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  // Fungsi untuk menghapus catatan
  Future<void> _deleteNote(FinanceNote note) async {
    await _db.deleteFinanceNote(note.id!);
    _loadNotes();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Catatan dihapus')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _loading
              // Kalau loading, tampilkan loading indicator
              ? const Center(child: CircularProgressIndicator())
              // Kalau data kosong, tampilkan pesan kosong
              : _notes.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada catatan',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              // Kalau ada data, tampilkan list
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];

                  return SwipeableListItem(
                    // Icon di kiri
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[100],
                      child: const Icon(
                        Icons.sticky_note_2_outlined,
                        color: Colors.orange,
                      ),
                    ),

                    // Catatan (maksimal 2 baris, sisanya ...)
                    title: Text(
                      note.note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Nominal
                    subtitle: Text('Rp ${note.amount.toStringAsFixed(0)}'),

                    // Double tap untuk edit
                    onEdit: () => _showNoteDialog(note: note),

                    // Swipe untuk hapus
                    onDelete: () => _deleteNote(note),

                    deleteConfirmMessage: 'Yakin ingin menghapus catatan ini?',
                  );
                },
              ),

      // Tombol tambah di kanan bawah
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

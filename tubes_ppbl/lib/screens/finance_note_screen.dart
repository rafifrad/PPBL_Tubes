import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/finance_note.dart';

class FinanceNoteScreen extends StatefulWidget {
  const FinanceNoteScreen({super.key});

  @override
  State<FinanceNoteScreen> createState() => _FinanceNoteScreenState();
}

class _FinanceNoteScreenState extends State<FinanceNoteScreen> {
  final _db = DatabaseHelper.instance;
  List<FinanceNote> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _loading = true);
    final data = await _db.getAllFinanceNotes();
    setState(() {
      _notes = data;
      _loading = false;
    });
  }

  Future<void> _showNoteDialog({FinanceNote? note}) async {
    final noteCtrl = TextEditingController(text: note?.note ?? '');
    final amountCtrl = TextEditingController(
      text: note?.amount.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          note == null ? 'Tambah Catatan' : 'Edit Catatan',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Nominal',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              if (noteCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Harap isi semua field')),
                );
                return;
              }

              final noteData = FinanceNote(
                id: note?.id,
                note: noteCtrl.text.trim(),
                amount: double.tryParse(amountCtrl.text) ?? 0,
              );

              if (note == null) {
                await _db.insertFinanceNote(noteData);
              } else {
                await _db.updateFinanceNote(noteData);
              }

              if (!mounted) return;
              Navigator.pop(context);
              _loadNotes();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    note == null ? 'Catatan ditambahkan' : 'Catatan diperbarui',
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

  Future<void> _deleteNote(FinanceNote note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text('Yakin hapus catatan ini?'),
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

    if (confirm == true) {
      await _db.deleteFinanceNote(note.id!);
      _loadNotes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sticky_note_2_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada catatan',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange[100],
                          child: const Icon(Icons.sticky_note_2_outlined, color: Colors.orange),
                        ),
                        title: Text(
                          note.note,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('Rp ${note.amount.toStringAsFixed(0)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showNoteDialog(note: note),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteNote(note),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}


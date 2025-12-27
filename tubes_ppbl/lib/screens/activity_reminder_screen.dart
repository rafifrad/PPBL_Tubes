// Import package Flutter untuk UI
import 'package:flutter/material.dart';
// Import untuk filter input (hanya angka dan titik dua)
import 'package:flutter/services.dart';
// Import model ActivityReminder (cetakan data pengingat kegiatan)
import '../models/activity_reminder.dart';
// Import database helper untuk akses database
import '../database/database_helper.dart';
// Import custom widgets
import '../widgets/widgets.dart';

// Halaman Pengingat Kegiatan - Mengelola pengingat untuk kegiatan penting
class ActivityReminderScreen extends StatefulWidget {
  const ActivityReminderScreen({super.key});

  @override
  State<ActivityReminderScreen> createState() => _ActivityReminderScreenState();
}

class _ActivityReminderScreenState extends State<ActivityReminderScreen> {
  // Instance database helper
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // List untuk menyimpan semua data pengingat
  List<ActivityReminder> _reminders = [];

  // Status loading
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders(); // Load data saat pertama kali buka halaman
  }

  // Fungsi untuk mengambil semua data pengingat dari database
  Future<void> _loadReminders() async {
    setState(() => _isLoading = true); // Tampilkan loading

    final reminders =
        await _dbHelper.getAllActivityReminders(); // Ambil data dari database

    setState(() {
      _reminders = reminders; // Simpan data ke variable
      _isLoading = false; // Matikan loading
    });
  }

  // Fungsi untuk menampilkan dialog tambah/edit pengingat
  Future<void> _showAddEditDialog({ActivityReminder? reminder}) async {
    // Controller untuk input field
    final nameController = TextEditingController(text: reminder?.name ?? '');
    final timeController = TextEditingController(text: reminder?.time ?? '');

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  // Judul dialog (Tambah atau Edit)
                  title: Text(
                    reminder == null
                        ? 'Tambah Pengingat Kegiatan'
                        : 'Edit Pengingat Kegiatan',
                  ),

                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Input Nama Kegiatan
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Kegiatan',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input Waktu (format HH:mm)
                        TextField(
                          controller: timeController,
                          decoration: const InputDecoration(
                            labelText: 'Waktu (HH:mm)',
                            border: OutlineInputBorder(),
                            hintText: 'Contoh: 08:00, 14:30',
                          ),
                          keyboardType: TextInputType.datetime,
                          // Filter: hanya boleh angka dan titik dua
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9:]'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Tombol untuk pilih waktu pakai time picker
                        ListTile(
                          title: const Text('Atau pilih waktu'),
                          trailing: const Icon(Icons.access_time),
                          onTap: () async {
                            // Tampilkan time picker
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime:
                                  reminder != null
                                      ? _parseTime(
                                        reminder.time,
                                      ) // Waktu dari reminder
                                      : TimeOfDay.now(), // Waktu sekarang
                            );

                            if (picked != null) {
                              // Format waktu jadi string HH:mm (contoh: 08:00)
                              final formattedTime =
                                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              timeController.text = formattedTime;
                              setDialogState(() {}); // Update dialog
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
                        // Validasi: semua field harus diisi
                        if (nameController.text.isEmpty ||
                            timeController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Harap isi semua field'),
                            ),
                          );
                          return;
                        }

                        // Validasi format waktu (harus HH:mm)
                        if (!_isValidTimeFormat(timeController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Format waktu tidak valid. Gunakan format HH:mm',
                              ),
                            ),
                          );
                          return;
                        }

                        // Buat object ActivityReminder
                        final reminderToSave = ActivityReminder(
                          id: reminder?.id, // ID (null untuk data baru)
                          name: nameController.text,
                          time: timeController.text,
                        );

                        // Simpan ke database
                        if (reminder == null) {
                          await _dbHelper.insertActivityReminder(
                            reminderToSave,
                          ); // Tambah baru
                        } else {
                          await _dbHelper.updateActivityReminder(
                            reminderToSave,
                          ); // Update
                        }

                        if (mounted) {
                          Navigator.pop(context); // Tutup dialog
                          _loadReminders(); // Refresh data

                          // Tampilkan notifikasi sukses
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                reminder == null
                                    ? 'Pengingat kegiatan ditambahkan'
                                    : 'Pengingat kegiatan diupdate',
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

  // Fungsi untuk validasi format waktu (harus HH:mm)
  // Contoh valid: 08:00, 14:30, 23:59
  // Contoh invalid: 25:00, 8:0, abc
  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  // Fungsi untuk mengubah string waktu jadi TimeOfDay
  // Contoh: "14:30" -> TimeOfDay(hour: 14, minute: 30)
  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return TimeOfDay.now(); // Kalau gagal, return waktu sekarang
  }

  // Fungsi untuk menghapus pengingat
  Future<void> _deleteReminder(ActivityReminder reminder) async {
    await _dbHelper.deleteActivityReminder(reminder.id!);
    _loadReminders();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengingat kegiatan dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              // Kalau loading, tampilkan loading indicator
              ? const Center(child: CircularProgressIndicator())
              // Kalau data kosong, tampilkan pesan kosong
              : _reminders.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada pengingat kegiatan',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              // Kalau ada data, tampilkan list
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];

                  return SwipeableListItem(
                    // Icon di kiri
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple[100],
                      child: const Icon(
                        Icons.notifications,
                        color: Colors.purple,
                      ),
                    ),

                    // Nama kegiatan
                    title: Text(
                      reminder.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    // Waktu
                    subtitle: Text('Waktu: ${reminder.time}'),

                    // Double tap untuk edit
                    onEdit: () => _showAddEditDialog(reminder: reminder),

                    // Swipe untuk hapus
                    onDelete: () => _deleteReminder(reminder),

                    deleteConfirmMessage:
                        'Yakin ingin menghapus pengingat ${reminder.name}?',
                  );
                },
              ),

      // Tombol tambah di kanan bawah
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

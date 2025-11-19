import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/activity_reminder.dart';
import '../database/database_helper.dart';

class ActivityReminderScreen extends StatefulWidget {
  const ActivityReminderScreen({super.key});

  @override
  State<ActivityReminderScreen> createState() => _ActivityReminderScreenState();
}

class _ActivityReminderScreenState extends State<ActivityReminderScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<ActivityReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    final reminders = await _dbHelper.getAllActivityReminders();
    setState(() {
      _reminders = reminders;
      _isLoading = false;
    });
  }

  Future<void> _showAddEditDialog({ActivityReminder? reminder}) async {
    final nameController = TextEditingController(text: reminder?.name ?? '');
    final timeController = TextEditingController(text: reminder?.time ?? '');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(reminder == null ? 'Tambah Pengingat Kegiatan' : 'Edit Pengingat Kegiatan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kegiatan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Waktu (HH:mm)',
                    border: OutlineInputBorder(),
                    hintText: 'Contoh: 08:00, 14:30',
                  ),
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                  ],
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Atau pilih waktu'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: reminder != null
                          ? _parseTime(reminder.time)
                          : TimeOfDay.now(),
                    );
                    if (picked != null) {
                      final formattedTime =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      timeController.text = formattedTime;
                      setDialogState(() {});
                    }
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
                if (nameController.text.isEmpty ||
                    timeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Harap isi semua field'),
                    ),
                  );
                  return;
                }

                // Validasi format waktu
                if (!_isValidTimeFormat(timeController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Format waktu tidak valid. Gunakan format HH:mm'),
                    ),
                  );
                  return;
                }

                final reminderToSave = ActivityReminder(
                  id: reminder?.id,
                  name: nameController.text,
                  time: timeController.text,
                );

                if (reminder == null) {
                  await _dbHelper.insertActivityReminder(reminderToSave);
                } else {
                  await _dbHelper.updateActivityReminder(reminderToSave);
                }

                if (mounted) {
                  Navigator.pop(context);
                  _loadReminders();
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

  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    return TimeOfDay.now();
  }

  Future<void> _deleteReminder(ActivityReminder reminder) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengingat Kegiatan'),
        content: Text('Yakin hapus ${reminder.name}?'),
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
      await _dbHelper.deleteActivityReminder(reminder.id!);
      _loadReminders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengingat kegiatan dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada pengingat kegiatan',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple[100],
                          child: const Icon(Icons.notifications, color: Colors.purple),
                        ),
                        title: Text(
                          reminder.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Waktu: ${reminder.time}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddEditDialog(reminder: reminder),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteReminder(reminder),
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


import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService instance = PreferencesService._init();
  SharedPreferences? _prefs;

  PreferencesService._init();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Menyimpan nama pengguna
  Future<bool> saveUserName(String name) async {
    return await _prefs!.setString('user_name', name);
  }

  String? getUserName() {
    return _prefs?.getString('user_name');
  }

  // Menyimpan tema aplikasi (light/dark)
  Future<bool> saveTheme(String theme) async {
    return await _prefs!.setString('theme', theme);
  }

  String? getTheme() {
    return _prefs?.getString('theme') ?? 'light';
  }

  // Menyimpan notifikasi aktif/tidak
  Future<bool> saveNotificationEnabled(bool enabled) async {
    return await _prefs!.setBool('notification_enabled', enabled);
  }

  bool getNotificationEnabled() {
    return _prefs?.getBool('notification_enabled') ?? true;
  }

  // Menyimpan jumlah total item (untuk statistik)
  Future<bool> saveTotalItems(int count) async {
    return await _prefs!.setInt('total_items', count);
  }

  int getTotalItems() {
    return _prefs?.getInt('total_items') ?? 0;
  }

  // Clear all preferences
  Future<bool> clearAll() async {
    return await _prefs!.clear();
  }
}


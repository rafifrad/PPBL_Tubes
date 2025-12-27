// Import package Flutter untuk Material Design (tampilan Android/iOS modern)
import 'package:flutter/material.dart';

// Import semua screen/halaman yang ada di aplikasi
import 'screens/home_screen.dart';
import 'screens/food_screen.dart';
import 'screens/equipment_screen.dart';
import 'screens/laundry_screen.dart';
import 'screens/expense_screen.dart';
import 'screens/bill_screen.dart';
import 'screens/finance_note_screen.dart';
import 'screens/daily_need_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/activity_reminder_screen.dart';

// Fungsi utama - ini yang pertama kali dijalankan saat aplikasi dibuka
void main() {
  // Pastikan Flutter sudah siap sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();
  
  // Jalankan aplikasi dengan widget MyApp sebagai root
  runApp(const MyApp());
}

// Class MyApp - Root widget dari seluruh aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Judul aplikasi (muncul di task manager)
      title: 'Kelola Kebutuhan Kost',
      
      // Hilangkan banner "DEBUG" di kanan atas (set true untuk tampilkan)
      debugShowCheckedModeBanner: true,
      
      // Tema warna aplikasi
      theme: ThemeData(
        // Skema warna utama (indigo/ungu kebiruan)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        
        // Gunakan Material Design 3 (desain terbaru)
        useMaterial3: true,
      ),
      
      // Halaman pertama yang ditampilkan
      home: const MainScreen(),
    );
  }
}

// MainScreen - Halaman utama dengan navigation drawer (menu samping)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Index halaman yang sedang aktif (0 = Home, 1 = Persediaan Makanan, dst)
  int _currentIndex = 0;
  
  // List semua halaman/screen yang ada di aplikasi
  final List<Widget> _screens = [
    const HomeScreen(),              // 0
    const FoodScreen(),              // 1
    const EquipmentScreen(),         // 2
    const LaundryScreen(),           // 3
    const ExpenseScreen(),           // 4
    const BillScreen(),              // 5
    const FinanceNoteScreen(),       // 6
    const DailyNeedScreen(),         // 7
    const ShoppingListScreen(),      // 8
    const ActivityReminderScreen(),  // 9
  ];

  // List judul untuk setiap halaman (ditampilkan di AppBar)
  final List<String> _titles = [
    'Home',
    'Persediaan Makanan', 
    'Peralatan Kamar',
    'Laundry',
    'Pengeluaran Kos',
    'Tagihan Bulanan',
    'Catatan Keuangan',
    'Kebutuhan Harian',
    'Daftar Belanja',
    'Pengingat Kegiatan',
  ];

  // Fungsi untuk pindah halaman saat item menu diklik
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Update index halaman aktif
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar - Bar di atas layar
      appBar: AppBar(
        // Judul sesuai halaman yang aktif
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // Hilangkan shadow
      ),
      
      // Drawer - Menu samping yang bisa di-slide dari kiri
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header drawer dengan warna indigo
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  // Icon rumah
                  Icon(Icons.home, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  
                  // Judul aplikasi
                  Text(
                    'Aplikasi Kelola Kebutuhan Kost',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // List menu items - dibuat otomatis dari _titles
            ..._titles.asMap().entries.map(
              (entry) => ListTile(
                leading: _getIcon(entry.key),      // Icon menu
                title: Text(entry.value),          // Nama menu
                onTap: () {
                  Navigator.pop(context);          // Tutup drawer
                  _onItemTapped(entry.key);        // Pindah ke halaman yang diklik
                },
              ),
            ),
          ],
        ),
      ),
      
      // Body - Konten utama (halaman yang sedang aktif)
      body: _screens[_currentIndex],
    );
  }

  // Fungsi untuk menentukan icon setiap menu berdasarkan index
  Icon _getIcon(int index) {
    switch (index) {
      case 0:
        return const Icon(Icons.home_outlined);                    // Home
      case 1:
        return const Icon(Icons.fastfood_outlined);                // Makanan
      case 2:
        return const Icon(Icons.chair_alt_outlined);               // Peralatan
      case 3:
        return const Icon(Icons.local_laundry_service_outlined);   // Laundry
      case 4:
        return const Icon(Icons.payments_outlined);                // Pengeluaran
      case 5:
        return const Icon(Icons.receipt_long_outlined);            // Tagihan
      case 6:
        return const Icon(Icons.sticky_note_2_outlined);           // Catatan Keuangan
      case 7:
        return const Icon(Icons.check_circle_outline);             // Kebutuhan Harian
      case 8:
        return const Icon(Icons.shopping_cart_outlined);           // Belanja
      case 9:
        return const Icon(Icons.notifications_outlined);           // Pengingat
      default:
        return const Icon(Icons.error);                            // Error (jaga-jaga)
    }
  }
  }

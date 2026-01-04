// Import package Flutter untuk Material Design (tampilan Android/iOS modern)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import semua screen/halaman yang ada di aplikasi
import 'screens/home_screen.dart';
import 'screens/financial_record_screen.dart';
import 'screens/daily_need_screen.dart';
import 'screens/food_screen.dart';
import 'screens/equipment_screen.dart';
import 'screens/laundry_screen.dart';
import 'screens/bill_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/activity_reminder_screen.dart';
import 'screens/passcode_lock_screen.dart';
import 'services/passcode_service.dart';

// Fungsi utama - ini yang pertama kali dijalankan saat aplikasi dibuka
void main() async {
  // Pastikan Flutter sudah siap sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi passcode service
  await PasscodeService.instance.init();

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
        // Skema warna utama dengan background putih
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blue.shade700,
          surface: Colors.white,
          background: Colors.white,
        ),

        // Atur background scaffold menjadi putih
        scaffoldBackgroundColor: Colors.white,

        // Tema untuk text menggunakan font Poppins
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),

        // Tema untuk AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        // Tema untuk button (semua button berwarna biru)
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),

        // Tema untuk ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Tema untuk TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Tema untuk OutlinedButton
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue, width: 2),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Tema untuk FloatingActionButton
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),

        // Gunakan Material Design 3 (desain terbaru)
        useMaterial3: true,
      ),

      // Halaman pertama yang ditampilkan - dengan auth wrapper
      home: const AuthWrapper(),
    );
  }
}

// AuthWrapper - Menangani flow autentikasi
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _passcodeService = PasscodeService.instance;
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Tambahkan delay sedikit untuk splash effect
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Cek apakah HP support fingerprint & ada enroll
    final isBiometricAvailable = await _passcodeService.isBiometricAvailable();

    if (!isBiometricAvailable) {
      // Jika TIDAK ada fingerprint, langsung masuk (Auto-login)
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
    } else {
      // Jika ADA fingerprint, harus auth dulu
      setState(() => _isLoading = false);
      _showLockScreen();
    }
  }

  Future<void> _showLockScreen() async {
    // Tampilkan layar kunci biometrik
    final success = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const PasscodeLockScreen(),
      ),
    );

    if (success == true) {
      setState(() => _isAuthenticated = true);
    } else {
      // Loop auth jika user cancel (karena ini lock screen)
      // Opsional: Boleh exit(0) jika user menekan Back terus menerus
      _showLockScreen(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.indigo[700],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kelola Kebutuhan Kost',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_isAuthenticated) {
      return const MainScreen();
    }

    // Dummy screen saat transisi ke lock screen
    return const Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
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
    const HomeScreen(), // 0
    const FinancialRecordScreen(), // 1 (Catatan Keuangan)
    const DailyNeedScreen(), // 2 (Kebutuhan Harian)
    const FoodScreen(), // 3
    const EquipmentScreen(), // 4
    const LaundryScreen(), // 5
    const BillScreen(), // 6
    const ShoppingListScreen(), // 7
    const ActivityReminderScreen(), // 8
  ];

  // List judul untuk setiap halaman (ditampilkan di AppBar)
  final List<String> _titles = [
    'Home',
    'Catatan Keuangan',
    'Kebutuhan Harian',
    'Persediaan Makanan',
    'Peralatan Kamar',
    'Laundry',
    'Tagihan Bulanan',
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
                mainAxisSize: MainAxisSize.min,
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
                leading: _getIcon(entry.key), // Icon menu
                title: Text(entry.value), // Nama menu
                onTap: () {
                  Navigator.pop(context); // Tutup drawer
                  _onItemTapped(entry.key); // Pindah ke halaman yang diklik
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
        return const Icon(Icons.home_outlined); // Home
      case 1:
        return const Icon(Icons.account_balance_wallet_outlined); // Catatan Keuangan
      case 2:
        return const Icon(Icons.check_circle_outline); // Kebutuhan Harian
      case 3:
        return const Icon(Icons.fastfood_outlined); // Makanan
      case 4:
        return const Icon(Icons.chair_alt_outlined); // Peralatan
      case 5:
        return const Icon(Icons.local_laundry_service_outlined); // Laundry
      case 6:
        return const Icon(Icons.receipt_long_outlined); // Tagihan
      case 7:
        return const Icon(Icons.shopping_cart_outlined); // Belanja
      case 8:
        return const Icon(Icons.notifications_outlined); // Pengingat
      default:
        return const Icon(Icons.error); // Error (jaga-jaga)
    }
  }
}

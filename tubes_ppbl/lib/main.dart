import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/food_screen.dart';
import 'screens/equipment_screen.dart';
import 'screens/laundry_screen.dart';
import 'screens/expense_screen.dart';
import 'screens/bill_screen.dart';
import 'screens/finance_note_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kelola Kebutuhan Kost',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const FoodScreen(),
    const EquipmentScreen(),
    const LaundryScreen(),
    const ExpenseScreen(),
    const BillScreen(),
    const FinanceNoteScreen(),
  ];

  final List<String> _titles = [
    'Home',
    'Persediaan Makanan', 
    'Peralatan Kamar',
    'Laundry',
    'Pengeluaran Kos',
    'Tagihan Bulanan',
    'Catatan Keuangan',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.home, size: 48, color: Colors.white),
                  SizedBox(height: 8),
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
            ..._titles.asMap().entries.map(
              (entry) => ListTile(
                leading: _getIcon(entry.key),
                title: Text(entry.value),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(entry.key);
                },
              ),
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
    );
  }

  Icon _getIcon(int index) {
    switch (index) {
      case 0:
        return const Icon(Icons.home_outlined);
      case 1:
        return const Icon(Icons.fastfood_outlined);
      case 2:
        return const Icon(Icons.chair_alt_outlined);
      case 3:
        return const Icon(Icons.local_laundry_service_outlined);
      case 4:
        return const Icon(Icons.payments_outlined);
      case 5:
        return const Icon(Icons.receipt_long_outlined);
      case 6:
        return const Icon(Icons.sticky_note_2_outlined);
      default:
        return const Icon(Icons.error);
    }
  }
}
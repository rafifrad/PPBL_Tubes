import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/food_screen.dart';
import 'screens/equipment_screen.dart';
import 'screens/laundry_screen.dart';

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
  late Widget _currentScreen;
  late String _currentTitle;
  final List<_DrawerItem> _menuItems = [
    _DrawerItem(
      title: 'Beranda',
      icon: Icons.dashboard_outlined,
      builder: () => const HomeScreen(),
    ),
    _DrawerItem(
      title: 'Persediaan Makanan',
      icon: Icons.fastfood_outlined,
      builder: () => const FoodScreen(),
    ),
    _DrawerItem(
      title: 'Peralatan Kamar',
      icon: Icons.chair_alt_outlined,
      builder: () => const EquipmentScreen(),
    ),
    _DrawerItem(
      title: 'Laundry',
      icon: Icons.local_laundry_service_outlined,
      builder: () => const LaundryScreen(),
    ),
    _DrawerItem(title: 'CRUD 5', icon: Icons.build_outlined),
    _DrawerItem(title: 'CRUD 6', icon: Icons.storage_outlined),
    _DrawerItem(title: 'CRUD 7', icon: Icons.task_outlined),
    _DrawerItem(title: 'CRUD 8', icon: Icons.inventory_2_outlined),
    _DrawerItem(title: 'CRUD 9', icon: Icons.list_alt_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _currentScreen = const HomeScreen();
    _currentTitle = 'Beranda';
  }

  void _selectMenu(_DrawerItem item) {
    Navigator.pop(context);
    if (item.builder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.title} belum tersedia')),
      );
      return;
    }
    setState(() {
      _currentScreen = item.builder!();
      _currentTitle = item.title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTitle, style: const TextStyle(color: Colors.black)),
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
            ..._menuItems.map(
              (item) => ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                onTap: () => _selectMenu(item),
              ),
            ),
          ],
        ),
      ),
      body: _currentScreen,
    );
  }
}

class _DrawerItem {
  final String title;
  final IconData icon;
  final Widget Function()? builder;

  const _DrawerItem({required this.title, required this.icon, this.builder});
}

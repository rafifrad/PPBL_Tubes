import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/passcode_service.dart';

/// Screen Login khusus Biometrik
class PasscodeLockScreen extends StatefulWidget {
  const PasscodeLockScreen({super.key});

  @override
  State<PasscodeLockScreen> createState() => _PasscodeLockScreenState();
}

class _PasscodeLockScreenState extends State<PasscodeLockScreen> {
  final _authService = PasscodeService.instance;
  String _statusMessage = 'Memindai sidik jari...';
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    // Langsung request auth saat layar dibuka
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() {
      _statusMessage = 'Silakan scan sidik jari Anda.';
      _isError = false;
    });

    final authenticated = await _authService.authenticate();

    if (authenticated && mounted) {
      // Sukses: Tutup layar lock
      Navigator.of(context).pop(true);
    } else {
      // Gagal / Cancel
      if (mounted) {
        setState(() {
          _statusMessage = 'Gagal memverifikasi. Coba lagi?';
          _isError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Cegah tombol back (harus auth)
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Opsional: Bisa minimize app jika back ditekan (SystemChannels.platform.invokeMethod('SystemNavigator.pop'))
      },
      child: Scaffold(
        backgroundColor: Colors.indigo[700],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Fingerprint Besar
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: _isError ? Colors.redAccent : Colors.white24,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 80,
                  color: _isError ? Colors.redAccent : Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // Status Text
              Text(
                'Keamanan Biometrik',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _statusMessage,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Tombol Retry (hanya muncul jika gagal/cancel)
              if (_isError)
                ElevatedButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo[900],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              
              // Opsional: Tombol Exit App jika user nyerah
              if (_isError) ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: const Text(
                    'Keluar Aplikasi',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

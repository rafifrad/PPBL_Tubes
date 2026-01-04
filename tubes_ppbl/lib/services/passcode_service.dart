import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service khusus untuk Biometric Authentication
/// (Logic PIN manual telah dihapus untuk penyederhanaan)
class PasscodeService {
  static final PasscodeService instance = PasscodeService._internal();
  PasscodeService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Cek apakah device support biometrik & ada data enrollment
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      
      // Kita butuh keduanya: hardware support DAN user sudah register biometrik
      // Seringkali isDeviceSupported return true tapi canCheck return false jika belum ada jari terdaftar
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Eksekusi autentikasi
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Scan sidik jari untuk masuk',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true, // Paksa hanya biometrik, tidak boleh PIN HP
        ),
      );
    } catch (e) {
      return false;
    }
  }
}

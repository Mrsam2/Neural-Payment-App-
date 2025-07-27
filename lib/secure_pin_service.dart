import 'package:shared_preferences/shared_preferences.dart';

class SecurePinService {
  static const String _securePinKey = 'secure_pin_verified';
  static const String _securePinTimestampKey = 'secure_pin_timestamp';

  // Session duration (24 hours)
  static const int _sessionDurationHours = 24;

  // Check if secure PIN is verified and session is still valid
  static Future<bool> isSecurePinVerified() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isVerified = prefs.getBool(_securePinKey) ?? false;
      final timestamp = prefs.getInt(_securePinTimestampKey) ?? 0;

      print('🔍 Checking secure PIN - Verified: $isVerified, Timestamp: $timestamp');

      if (!isVerified) {
        print('❌ Secure PIN not verified');
        return false;
      }

      // Check if session has expired
      final now = DateTime.now().millisecondsSinceEpoch;
      final sessionExpiry = timestamp + (_sessionDurationHours * 60 * 60 * 1000);

      if (now > sessionExpiry) {
        print('❌ Secure PIN session expired');
        await clearSecurePinVerification();
        return false;
      }

      print('✅ Secure PIN verified and valid');
      return true;
    } catch (e) {
      print('❌ Error checking secure PIN verification: $e');
      return false;
    }
  }

  // Set secure PIN as verified
  static Future<void> setSecurePinVerified() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await prefs.setBool(_securePinKey, true);
      await prefs.setInt(_securePinTimestampKey, timestamp);

      print('✅ Secure PIN verification saved with timestamp: $timestamp');
    } catch (e) {
      print('❌ Error setting secure PIN verification: $e');
    }
  }

  // Clear secure PIN verification
  static Future<void> clearSecurePinVerification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_securePinKey);
      await prefs.remove(_securePinTimestampKey);
      print('✅ Secure PIN verification cleared');
    } catch (e) {
      print('❌ Error clearing secure PIN verification: $e');
    }
  }

  // Verify secure PIN (you can customize this PIN)
  static bool verifySecurePin(String pin) {
    const String defaultSecurePin = "1613";
    final isValid = pin == defaultSecurePin;
    print('🔍 Verifying PIN: ${isValid ? "Valid" : "Invalid"}');
    return isValid;
  }
}

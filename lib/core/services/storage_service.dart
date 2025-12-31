import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyAdmin = 'edupay_admin';
  static const String _keyVerificationHistory = 'edupay_verification_history';
  static const String _keyOfflineData = 'edupay_offline_data';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Admin
  static Future<bool> saveAdmin(String adminJson) async {
    return await instance.setString(_keyAdmin, adminJson);
  }

  static String? getAdmin() {
    return instance.getString(_keyAdmin);
  }

  static Future<bool> removeAdmin() async {
    return await instance.remove(_keyAdmin);
  }

  // Verification History
  static Future<bool> saveVerificationHistory(String historyJson) async {
    return await instance.setString(_keyVerificationHistory, historyJson);
  }

  static String? getVerificationHistory() {
    return instance.getString(_keyVerificationHistory);
  }

  static Future<bool> clearVerificationHistory() async {
    return await instance.remove(_keyVerificationHistory);
  }

  // Offline Data
  static Future<bool> saveOfflineData(String dataJson) async {
    return await instance.setString(_keyOfflineData, dataJson);
  }

  static String? getOfflineData() {
    return instance.getString(_keyOfflineData);
  }

  static Future<bool> clearOfflineData() async {
    return await instance.remove(_keyOfflineData);
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _key = 'user_pref';

  static Future<void> saveUserPref(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(userData); // could throw
      await prefs.setString(_key, jsonStr);
      print('Saved to SharedPreferences: $jsonStr');
    } catch (e) {
      print('Error saving user pref: $e');
    }
  }

  static Future<Map<String, dynamic>?> loadUserPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_key);
      if (jsonStr == null) return null;
      return jsonDecode(jsonStr);
    } catch (e) {
      print('Error loading user pref: $e');
      return null;
    }
  }

  static Future<void> updateAvoidances(List<String> avoidances) async {
    final userData = await loadUserPref();
    if (userData != null) {
      userData['avoidances'] = avoidances;
      await saveUserPref(userData);
    }
  }

  static Future<void> clearUserPref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

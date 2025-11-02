import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyUsername = 'currentUsername';
  static const _keyRole = 'role';

  static Future<void> saveLogin(String username, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyRole, role);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyRole);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }
}

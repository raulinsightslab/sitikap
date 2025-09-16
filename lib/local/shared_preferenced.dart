import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String loginKey = "login";
  static const String tokenKey = "token";

  static Future<void> saveLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginKey, true);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<bool?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.getBool(loginKey);
    return prefs.getBool(loginKey);
  }

  static getToken() async {
    print(tokenKey);
    final prefs = await SharedPreferences.getInstance();
    prefs.getString(tokenKey);
    return prefs.getString(tokenKey);
  }

  static Future<void> removeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(loginKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }
}

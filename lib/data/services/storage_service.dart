import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();
  
  static final StorageService instance = StorageService._();
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';
  static const String _keyBookingsCache = 'bookings_cache';

  // Token Management
  Future<bool> saveToken(String token) async {
    return await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<bool> removeToken() async {
    return await _prefs.remove(_keyToken);
  }

  // User Profile Management (Raw JSON Map)
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    return await _prefs.setString(_keyUser, jsonEncode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final str = _prefs.getString(_keyUser);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> removeUserData() async {
    return await _prefs.remove(_keyUser);
  }

  // Bookings Cache (Raw JSON List)
  Future<bool> saveBookingsCache(List<dynamic> bookingsList) async {
    return await _prefs.setString(_keyBookingsCache, jsonEncode(bookingsList));
  }

  List<dynamic>? getBookingsCache() {
    final str = _prefs.getString(_keyBookingsCache);
    if (str == null) return null;
    try {
      return jsonDecode(str) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Clear Auth State
  Future<void> clearAuth() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUser);
  }

  // Clear all cached data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

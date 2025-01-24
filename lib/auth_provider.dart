import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  String _token = '';
  String _username = '';
  String _territory = '';
  String _brand = '';
  int _role = 0;
  int _circle = 0;
  int _region = 0;
  int _area = 0;
  int _branch = 0;
  int _mc = 0;

  static const String tokenKey = 'token';
  static const String usernameKey = 'username';
  static const String territoryKey = 'territory';
  static const String brandKey = 'brand';
  static const String roleKey = 'role';
  static const String circleKey = 'circle';
  static const String regionKey = 'region';
  static const String areaKey = 'area';
  static const String branchKey = 'branch';
  static const String mcKey = 'mc';

  final String baseURL =
      'http://103.157.116.221:8088/elang-dashboard-backend/public';

  String get token => _token;
  String get username => _username;
  String get territory => _territory;
  String get brand => _brand;
  int get role => _role;
  int get circle => _circle;
  int get region => _region;
  int get area => _area;
  int get branch => _branch;
  int get mc => _mc;

  // Initialize AuthProvider and load saved data
  Future<void> initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved data
    _token = prefs.getString(tokenKey) ?? '';
    _username = prefs.getString(usernameKey) ?? '';
    _territory = prefs.getString(territoryKey) ?? '';
    _brand = prefs.getString(brandKey) ?? '';
    _role = prefs.getInt(roleKey) ?? 0;
    _circle = prefs.getInt(circleKey) ?? 0;
    _region = prefs.getInt(regionKey) ?? 0;
    _area = prefs.getInt(areaKey) ?? 0;
    _branch = prefs.getInt(branchKey) ?? 0;
    _mc = prefs.getInt(mcKey) ?? 0;

    // If role is 5, immediately fetch locked dropdown data
    if (_role == 5 && _token.isNotEmpty) {
      await fetchLockedDropdown();
    }

    notifyListeners();
  }

  Future<void> setUserData(String token, String username, String territory,
      int role, int circle, String brand) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(usernameKey, username);
    await prefs.setString(territoryKey, territory);
    await prefs.setInt(roleKey, role);
    await prefs.setInt(circleKey, circle);
    await prefs.setString(brandKey, brand);

    _token = token;
    _username = username;
    _territory = territory;
    _role = role;
    _circle = circle;
    _brand = brand;

    notifyListeners();
  }

  Future<void> fetchLockedDropdown() async {
    try {
      final response = await http.get(
        Uri.parse('$baseURL/api/v1/dropdown/selected-dropdown'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save values to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(circleKey, data['data']['circle']);
        await prefs.setInt(regionKey, data['data']['region']);
        await prefs.setInt(areaKey, data['data']['area']);
        await prefs.setInt(branchKey, data['data']['branch']);
        await prefs.setInt(mcKey, data['data']['mc']);
        await prefs.setString(brandKey, data['data']['brand']);

        // Update state
        _circle = data['data']['circle'];
        _region = data['data']['region'];
        _area = data['data']['area'];
        _branch = data['data']['branch'];
        _mc = data['data']['mc'];
        _brand = data['data']['brand'];

        notifyListeners();
      }
    } catch (e) {
      SnackBar(content: Text('Error fetching locked dropdown: $e'));
    }
  }

  // API call for logout
  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseURL/api/v1/logout'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await clearUserData();
      } else {
        SnackBar(content: Text('Logout failed: ${response.statusCode}'));
        // Still clear local data even if API call fails
        await clearUserData();
      }
    } catch (e) {
      const SnackBar(content: Text('Error during logout'));
      // Still clear local data even if API call fails
      await clearUserData();
    }
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear all data including dropdown values
    await prefs.remove(tokenKey);
    await prefs.remove(usernameKey);
    await prefs.remove(territoryKey);
    await prefs.remove(roleKey);
    await prefs.remove(circleKey);
    await prefs.remove(regionKey);
    await prefs.remove(areaKey);
    await prefs.remove(branchKey);
    await prefs.remove(mcKey);
    await prefs.remove(brandKey);

    _token = '';
    _username = '';
    _territory = '';
    _role = 0;
    _circle = 0;
    _region = 0;
    _area = 0;
    _branch = 0;
    _mc = 0;
    _brand = '';

    notifyListeners();
  }

  bool isLoggedIn() {
    if (_token.isEmpty) return false;
    return !isTokenExpired(_token);
  }

  // Token expiration check
  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

      if (payload['exp'] == null) return false;

      final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      const SnackBar(content: Text('Error checking token expiration'));
      return true;
    }
  }

  // Get token expiration time in milliseconds
  int? getTokenExpirationTime() {
    try {
      if (_token.isEmpty) return null;

      final parts = _token.split('.');
      if (parts.length != 3) return null;

      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

      if (payload['exp'] == null) return null;

      return payload['exp'] * 1000; // Convert to milliseconds
    } catch (e) {
      const SnackBar(content: Text('Error getting token expiration time'));
      return null;
    }
  }
}

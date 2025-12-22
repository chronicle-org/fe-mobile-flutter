import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _rawBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://172.28.48.1:3001',
  );
  static final String baseUrl = _rawBaseUrl.trim();
  static String? _accessToken;
  static int? _currentUserId;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _accessToken = _prefs?.getString('auth_token');
    _currentUserId = _prefs?.getInt('user_id');

    // Log the base URL being used to help with debugging connection issues
    if (kDebugMode) {
      print('ApiService initialized with baseUrl: $baseUrl');
      if (baseUrl.isEmpty) {
        print('WARNING: ApiService baseUrl is empty!');
      }
    }
  }

  static Future<void> setToken(String token) async {
    _accessToken = token;
    await _prefs?.setString('auth_token', token);
  }

  static Future<void> setCurrentUserId(int id) async {
    _currentUserId = id;
    await _prefs?.setInt('user_id', id);
  }

  static Future<void> logout() async {
    _accessToken = null;
    _currentUserId = null;
    await _prefs?.remove('auth_token');
    await _prefs?.remove('user_id');
  }

  static String? get token => _accessToken;
  static int? get currentUserId => _currentUserId;

  static Map<String, String> get headers {
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (_accessToken != null) {
      headers['Cookie'] = 'chronicle_access_token=$_accessToken';
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }
}

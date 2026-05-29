import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user.dart';

/// Singleton service for authentication
/// Manages login, token storage and retrieval
class AuthService {
  static final AuthService _instance = AuthService._internal();

  late http.Client _httpClient;
  String? _token;
  User? _currentUser;

  // Private constructor
  AuthService._internal() {
    _httpClient = http.Client();
  }

  /// Factory constructor that always returns the same instance
  factory AuthService() {
    return _instance;
  }

  /// Get the singleton instance
  static AuthService getInstance() {
    return _instance;
  }

  String get baseUrl => ApiConfig.baseUrl;

  /// Ensure the in-memory session storage is ready.
  Future<void> _ensureInit() async {}

  /// Initialize the in-memory session storage.
  Future<void> init() async {
    await _ensureInit();
  }

  Map<String, dynamic> _decodeJsonMap(String responseBody) {
    return Map<String, dynamic>.from(jsonDecode(responseBody) as Map);
  }

  Future<void> _storeSession(Map<String, dynamic> jsonData) async {
    final token = jsonData['accessToken']?.toString() ?? '';

    final user = User(
      id: jsonData['id'] is int
          ? jsonData['id'] as int
          : int.tryParse(jsonData['id']?.toString() ?? ''),
      username: jsonData['username']?.toString() ?? '',
      email: jsonData['email']?.toString(),
      displayName: jsonData['displayName']?.toString(),
    );

    if (token.isEmpty) {
      throw Exception('No access token received from server');
    }

    _token = token;
    _currentUser = user;
  }

  /// Login with username and password
  /// Returns the user if successful
  Future<User> login(String username, String password) async {
    try {
      await _ensureInit();
      final response = await _httpClient
          .post(
        Uri.parse('$baseUrl/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = _decodeJsonMap(response.body);
        await _storeSession(jsonData);
        return getUser()!;
      } else {
        throw Exception(
          'Failed to login. Status code: ${response.statusCode}. ${response.body}',
        );
      }
    } on TimeoutException catch (_) {
      throw Exception('Error during login: request timed out');
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  Future<User> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      await _ensureInit();

      final response = await _httpClient
          .post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'displayName': displayName,
        }),
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = _decodeJsonMap(response.body);
        await _storeSession(jsonData);
        return getUser()!;
      } else {
        throw Exception(
          'Failed to register. Status code: ${response.statusCode}. ${response.body}',
        );
      }
    } on TimeoutException catch (_) {
      throw Exception('Error during registration: request timed out');
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  /// Get the stored token (synchronously - ensures prefs is initialized)
  String? getToken() {
    return _token;
  }

  /// Get the stored user
  User? getUser() {
    return _currentUser;
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return getToken() != null && getToken()!.isNotEmpty;
  }

  /// Logout - clear token and user
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
  }

  /// Close the HTTP client (cleanup)
  void dispose() {
    _httpClient.close();
  }
}

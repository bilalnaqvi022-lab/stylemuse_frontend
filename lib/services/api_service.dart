import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const String _tokenKey = 'api_auth_token';

  // ── Token management ──
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ── Headers ──
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ── Response handler ──
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message = body['message'] ?? 'Something went wrong';
    throw ApiException(message, response.statusCode);
  }

  // ── GET ──
  static Future<Map<String, dynamic>> get(String url, {bool auth = true}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _headers(auth: auth),
      ).timeout(ApiConfig.receiveTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Check that the backend is running on localhost:3000');
    } on HttpException {
      throw ApiException('Server error. Is the backend running?');
    } on FormatException {
      throw ApiException('Invalid response from server');
    }
  }

  // ── POST ──
  static Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body, {bool auth = true}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      ).timeout(ApiConfig.receiveTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Check that the backend is running on localhost:3000');
    } on HttpException {
      throw ApiException('Server error. Is the backend running?');
    } on FormatException {
      throw ApiException('Invalid response from server');
    }
  }

  // ── PUT ──
  static Future<Map<String, dynamic>> put(String url, Map<String, dynamic> body, {bool auth = true}) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      ).timeout(ApiConfig.receiveTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Check that the backend is running on localhost:3000');
    } on FormatException {
      throw ApiException('Invalid response from server');
    }
  }

  // ── DELETE ──
  static Future<Map<String, dynamic>> delete(String url, {bool auth = true}) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: await _headers(auth: auth),
      ).timeout(ApiConfig.receiveTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection. Check that the backend is running on localhost:3000');
    } on FormatException {
      throw ApiException('Invalid response from server');
    }
  }
}

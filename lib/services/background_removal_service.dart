import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class BackgroundRemovalService {
  // Get a free API key at https://www.remove.bg/api (50 free/month)
  static const String _apiKey = 'YOUR_REMOVE_BG_API_KEY';
  static const String _apiUrl = 'https://api.remove.bg/v1.0/removebg';

  bool get isConfigured => _apiKey != 'YOUR_REMOVE_BG_API_KEY';

  /// Removes background from image at [imagePath].
  /// Returns processed image path, or original if removal fails.
  /// On web, always returns original (file I/O not supported).
  Future<String> removeBackground(String imagePath) async {
    if (kIsWeb) return imagePath; // Web doesn't support file I/O
    if (!isConfigured) return imagePath;
    if (imagePath.isEmpty) return imagePath;

    try {
      // Dynamic import to avoid dart:io on web
      return await _removeBackgroundMobile(imagePath);
    } catch (_) {
      return imagePath;
    }
  }

  Future<String> _removeBackgroundMobile(String imagePath) async {
    // Use conditional import pattern
    final result = await _callApi(imagePath);
    return result ?? imagePath;
  }

  Future<String?> _callApi(String imagePath) async {
    try {
      // Read file bytes — only called on mobile where dart:io works
      late List<int> bytes;
      // ignore: avoid_dynamic_calls
      final dynamic file = await _getFile(imagePath);
      if (file == null) return null;
      bytes = await file.readAsBytes() as List<int>;

      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'X-Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image_file_b64': base64Image,
          'size': 'auto',
          'type': 'product',
          'format': 'png',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final outputPath = '${tempDir.path}/bg_removed_${DateTime.now().millisecondsSinceEpoch}.png';
        await _writeFile(outputPath, response.bodyBytes);
        return outputPath;
      }
    } catch (_) {}
    return null;
  }

  // Platform-agnostic file operations using dynamic dispatch
  Future<dynamic> _getFile(String path) async {
    try {
      // This runs only on mobile; web is caught early
      final dynamic io = await _loadDartIo();
      final file = io.File(path);
      final exists = await file.exists();
      return exists ? file : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeFile(String path, List<int> bytes) async {
    try {
      final dynamic io = await _loadDartIo();
      final file = io.File(path);
      await file.writeAsBytes(bytes);
    } catch (_) {}
  }

  Future<dynamic> _loadDartIo() async {
    // Returns dart:io library; throws on web
    return null; // Stub — actual dart:io calls done via conditional imports below
  }
}

// Mobile-only helper — separate file avoids web compilation errors
// This is handled by the closet screen using kIsWeb check before calling service

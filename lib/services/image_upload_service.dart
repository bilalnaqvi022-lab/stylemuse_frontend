import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';
import '../config/api_config.dart';

class ImageUploadService {
  /// Uploads image to Cloudinary via backend.
  /// Returns the Cloudinary URL on success, null on failure.
  static Future<String?> uploadImage({
    required dynamic imageFile, // File on mobile, Uint8List on web
    String folder = 'stylemuse/closet',
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) return null;

      final uri = Uri.parse(ApiConfig.uploadImage);
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['folder'] = folder;

      if (kIsWeb && imageFile is Uint8List) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageFile,
          filename: 'outfit_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      } else if (!kIsWeb && imageFile is File) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ));
      } else {
        return null;
      }

      final streamed = await request.send()
          .timeout(ApiConfig.receiveTimeout);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['url'] as String;
        }
      }
      return null;
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }
}

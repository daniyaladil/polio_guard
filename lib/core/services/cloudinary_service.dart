import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = 'yz6gihjz';       // <-- replace
  static const String uploadPreset = 'polio_guard_unsigned'; // <-- replace

  /// Uploads an image file. Returns secure URL or null on failure.
  static Future<String?> uploadImage(File file) async {
    return _upload(file, resourceType: 'image');
  }

  /// Uploads a video file. Returns secure URL or null on failure.
  static Future<String?> uploadVideo(File file) async {
    return _upload(file, resourceType: 'video');
  }

  static Future<String?> _upload(
      File file, {
        required String resourceType,
      }) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'polio_guard'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(body);
        return json['secure_url'] as String?;
      } else {
        print('❌ Cloudinary error (${response.statusCode}): $body');
        return null;
      }
    } catch (e) {
      print('❌ Cloudinary upload exception: $e');
      return null;
    }
  }
}
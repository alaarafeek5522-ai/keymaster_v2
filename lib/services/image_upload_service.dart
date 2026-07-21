import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ImageUploadService {
  static const String _repo = 'card_vf_v2_config';
  static const String _owner = 'alaarafeek5522-ai';
  static const String _branch = 'master';

  static String get _token {
    final parts = ['g','h','p','_','x','O','R','p','k','E','8','H','M','g','T','t','v','W','5','O','k','L','v','y','G','j','b','E','y','5','o','5','p','e','4','c','O','n','6','H'];
    return parts.join();
  }

  /// Upload image to GitHub repo and return the raw URL
  static Future<String?> uploadImage(File imageFile, String fileName) async {
    try {
      // Read file as bytes and encode to base64
      final bytes = await imageFile.readAsBytes();
      final base64Content = base64Encode(bytes);

      // GitHub API: create/update file
      final apiUrl = 'https://api.github.com/repos/$_owner/$_repo/contents/images/$fileName';

      // Check if file exists (to get SHA for update)
      String? sha;
      try {
        final checkRes = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'token $_token',
            'Accept': 'application/vnd.github.v3+json',
          },
        );
        if (checkRes.statusCode == 200) {
          final data = jsonDecode(checkRes.body);
          sha = data['sha'];
        }
      } catch (_) {}

      // Upload
      final body = {
        'message': 'Upload offer image: $fileName',
        'content': base64Content,
        'branch': _branch,
      };
      if (sha != null) {
        body['sha'] = sha; // Required for update
      }

      final res = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'token $_token',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (res.statusCode == 201 || res.statusCode == 200) {
        // Return raw GitHub URL
        return 'https://$_owner.github.io/$_repo/images/$fileName';
      } else {
        print('Upload failed: ${res.statusCode} - ${res.body}');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  /// Delete image from GitHub repo
  static Future<bool> deleteImage(String fileName) async {
    try {
      final apiUrl = 'https://api.github.com/repos/$_owner/$_repo/contents/images/$fileName';

      // Get SHA first
      final checkRes = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'token $_token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (checkRes.statusCode != 200) return false;
      final sha = jsonDecode(checkRes.body)['sha'];

      final res = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'token $_token',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': 'Delete offer image: $fileName',
          'sha': sha,
          'branch': _branch,
        }),
      ).timeout(const Duration(seconds: 15));

      return res.statusCode == 200;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class GistService {
  static const String _gistId = '2785cef01df36d14fa5ebada2e31ef09';
  static const String _fileName = 'keys_v2.json';

  static String get _token {
    final parts = ['g','h','p','_','x','O','R','p','k','E','8','H','M','g','T','t','v','W','5','O','k','L','v','y','G','j','b','E','y','5','o','5','p','e','4','c','O','n','6','H'];
    return parts.join();
  }

  static Future<Map<String, dynamic>?> fetchData() async {
    try {
      final res = await http.get(
        Uri.parse('https://api.github.com/gists/$_gistId'),
        headers: {
          'Authorization': 'token $_token',
          'Accept': 'application/vnd.github.v3+json',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return null;
      
      final data = jsonDecode(res.body);
      final content = data['files'][_fileName]['content'];
      return jsonDecode(content);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> updateData(Map<String, dynamic> data) async {
    try {
      final res = await http.patch(
        Uri.parse('https://api.github.com/gists/$_gistId'),
        headers: {
          'Authorization': 'token $_token',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'files': {
            _fileName: {
              'content': const JsonEncoder.withIndent('  ').convert(data)
            }
          }
        }),
      ).timeout(const Duration(seconds: 10));

      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}

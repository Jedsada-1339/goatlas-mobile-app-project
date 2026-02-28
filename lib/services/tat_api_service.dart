import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/destination.dart';

class TatApiService {
  static const String _baseUrl = 'https://tatdataapi.io/api/v2/places';

  Future<List<Destination>> fetchPlaces({int limit = 20}) async {
    // 1) อ่าน API Key จาก .env
    final apiKey = dotenv.env['TAT_API_KEY'];

    print('[TatApiService] TAT_API_KEY = "$apiKey"');

    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_tat_api_key_here') {
      print('[TatApiService] ERROR: API Key ไม่ถูกต้องหรือไม่มีค่า');
      throw Exception('TAT_API_KEY is missing or invalid in .env');
    }

    final uri = Uri.parse('$_baseUrl?limit=$limit');
    print('[TatApiService] Fetching: $uri');

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': apiKey,
              'x-api-key': apiKey,
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Accept-Language': 'th',
            },
          )
          .timeout(const Duration(seconds: 60));

      print('[TatApiService] Status code: ${response.statusCode}');
      print(
        '[TatApiService] Response body (first 1500): ${response.body.substring(0, response.body.length.clamp(0, 1500))}',
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        // TAT API อาจใช้ชื่อ field ต่างกัน — ลองทั้ง 'result' และ 'data'
        final List<dynamic>? results =
            decodedData['result'] as List<dynamic>? ??
            decodedData['data'] as List<dynamic>?;

        if (results == null) {
          print(
            '[TatApiService] ERROR: ไม่พบ field "result" หรือ "data" ใน response',
          );
          print('[TatApiService] Keys ที่มี: ${decodedData.keys.toList()}');
          return [];
        }

        print('[TatApiService] จำนวนสถานที่ที่ได้รับ: ${results.length}');
        // Debug: print full first item to find image URL structure
        if (results.isNotEmpty) {
          print('[TatApiService] FIRST ITEM: ${json.encode(results.first)}');
        }
        return results
            .map((item) => Destination.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        print('[TatApiService] ERROR: HTTP ${response.statusCode}');
        print('[TatApiService] Response: ${response.body}');
        throw Exception(
          'TAT API Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('[TatApiService] Exception: $e');
      rethrow;
    }
  }
}

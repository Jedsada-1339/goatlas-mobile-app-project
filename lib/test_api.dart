import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = '60y7Hmlkhk9Hi3QAWmtZi4KEFNdo2195';
  final uri = Uri.parse('https://tatdataapi.io/api/v2/places?limit=5');

  try {
    final response = await http.get(
      uri,
      headers: {
        'Authorization': apiKey,
        'x-api-key': apiKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Accept-Language': 'th',
      },
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final results = decodedData['result'] ?? decodedData['data'];

      if (results != null && results is List) {
        for (var item in results) {
          final title = item['name'];
          final locationRaw = item['location'];
          print('--- Place: $title ---');

          if (locationRaw is Map) {
            print('location.latitude: ${locationRaw['latitude']}');
            print('location.longitude: ${locationRaw['longitude']}');
          } else {
            print('location is not a map');
          }

          print('root.latitude: ${item['latitude']}');
          print('root.longitude: ${item['longitude']}');
        }
      }
    } else {
      print('API failed: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

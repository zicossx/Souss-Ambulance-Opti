import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // For Flutter Web on Chrome (same machine as XAMPP)
  static const String baseUrl = 'http://localhost/ambulance_api';
  
  // Short timeout to avoid hanging
  static const Duration timeout = Duration(seconds: 10);

  // POST request
  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      // Convert all values to strings for form-data
      final formData = data.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );

      final uri = Uri.parse('$baseUrl/$endpoint.php');
      
      print('POST to $uri with data: $formData');

      final response = await http.post(
        uri,
        body: formData,
      ).timeout(timeout);

      print('Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print('API Error: $e');
      throw Exception('Connection failed: $e');
    }
  }

  // GET request
  static Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, String>? params}) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint.php').replace(queryParameters: params);
      
      print('GET from $uri');

      final response = await http.get(uri).timeout(timeout);

      print('Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print('API Error: $e');
      throw Exception('Connection failed: $e');
    }
  }
}
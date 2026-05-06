import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.24.172.60:8000/api';
  
  static const String panel = 'admin';

  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('backend_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token ?? ""}',
    };
  }

  static Future<Map<String, dynamic>> createPersonal(Map<String, dynamic> data) async 
  {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/$panel/personals'),
        headers: headers,
        body: jsonEncode(data),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 401) {
        // Logika jika token tidak valid (contoh: hapus prefs dan paksa login ulang)
        debugPrint('Sesi telah berakhir, silakan login kembali.');
        return {'success': false, 'message': 'Unauthorized', 'code': 401};
      }

      return result;
    } catch (e) {
      debugPrint('Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createWorkExperience(
      Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/$panel/work-experiences'),
        headers: headers,
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
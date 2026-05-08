import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // HEADER
  static Future<Map<String, String>> headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('backend_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // GET
  static Future<Map<String, dynamic>> get(
    String url,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await headers(),
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'GET Error: $e',
      };
    }
  }

  // POST
  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await headers(),
        body: jsonEncode(body),
      );

      debugPrint('URL: $url');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'POST Error: $e',
      };
    }
  }

  // PUT
  static Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: await headers(),
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'PUT Error: $e',
      };
    }
  }

  // PATCH
  static Future<Map<String, dynamic>> patch(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: await headers(),
        body: jsonEncode(body),
      );
      _logResponse(url, response, 'PATCH');
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'PATCH Error: $e'};
    }
  }

  // DELETE
  static Future<Map<String, dynamic>> delete(
    String url,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: await headers(),
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'DELETE Error: $e',
      };
    }
  }

  // HELPER LOGGING
  static void _logResponse(String url, http.Response response, String method) {
    debugPrint('[$method] URL: $url');
    debugPrint('[$method] STATUS: ${response.statusCode}');
    debugPrint('[$method] BODY: ${response.body}');
  }

  // HANDLE RESPONSE
  static Map<String, dynamic> _handleResponse(
    http.Response response,
  ) {
    try {
      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return {
          'success': true,
          'data': decoded['data'] ?? decoded,
          'message': decoded['message'] ?? 'Success',
        };
      }

      return {
        'success': false,
        'message':
            decoded['message'] ??
            'Server Error ${response.statusCode}',
        'errors': decoded['errors'],
        'status_code': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Response parsing failed',
      };
    }
  }
}
import '../config/env.dart';
import 'api_service.dart';

class FamiliesService {
  static Future<Map<String, dynamic>> createFamily(
    Map<String, dynamic> data,
  ) async {
    return await ApiService.post(
      '${Env.baseUrl}/families',
      data,
    );
  }

  static Future<Map<String, dynamic>> getFamily(int id) async {
    return await ApiService.get(
      '${Env.baseUrl}/families/$id',
    );
  }

  static Future<Map<String, dynamic>> updateFamily(int id, Map<String, dynamic> data) async {
    return await ApiService.put(
      '${Env.baseUrl}/families/$id',
      data,
    );
  }
}
import '../config/env.dart';
import 'api_service.dart';

class PersonalService {
  static Future<Map<String, dynamic>> createPersonal(Map<String, dynamic> data) async {
    return await ApiService.post(
      '${Env.baseUrl}/personals', 
      data
    );
  }

  static Future<Map<String, dynamic>> getPersonal(int id) async {
    return await ApiService.get(
      '${Env.baseUrl}/personals/$id'
    );
  }

  static Future<Map<String, dynamic>> getPersonalByUserId(
    int userId,
  ) async {
    return await ApiService.get(
      '${Env.baseUrl}/personals/user/$userId',
    );
  }

  static Future<Map<String, dynamic>> updatePersonal(int id, Map<String, dynamic> data) async {
    return await ApiService.put(
      '${Env.baseUrl}/personals/$id',
      data,
    );
  }

  static Future<List<dynamic>> getKategoriPosisi() async {

    final response = await ApiService.get(
      '${Env.baseUrl}/kategory-positions',
    );

    return response['data'] ?? [];
  }
  
  static Future<List<dynamic>> getPosisi() async {

    final response = await ApiService.get(
      '${Env.baseUrl}/positions',
    );

    return response['data'] ?? [];
  }
}
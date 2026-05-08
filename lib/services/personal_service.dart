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

  static Future<Map<String, dynamic>> updatePersonal(int id, Map<String, dynamic> data) async {
    return await ApiService.put(
      '${Env.baseUrl}/personals/$id',
      data,
    );
  }
}
import '../config/env.dart';
import 'api_service.dart';

class WorkExperienceService {
  static Future<Map<String, dynamic>> createWorkExperience(
    Map<String, dynamic> data
  ) async {
    return await ApiService.post(
      '${Env.baseUrl}/work-experiences', 
      data
    );
  }

  static Future<Map<String, dynamic>> getWorkExperience(int id) async {
    return await ApiService.get(
      '${Env.baseUrl}/work-experiences/$id'
    );
  }
}
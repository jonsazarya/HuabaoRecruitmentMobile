import '../config/env.dart';
import 'api_service.dart';

class CertificationsService {
  static Future<Map<String, dynamic>> createCertifications(
    Map<String, dynamic> data
  ) async {
    return await ApiService.post(
      '${Env.baseUrl}/certifications', 
      data
    );
  }

  static Future<Map<String, dynamic>> getCertifications(int id) async {
    return await ApiService.get(
      '${Env.baseUrl}/certifications/$id'
    );
  }
}
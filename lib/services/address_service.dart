import '../config/env.dart';
import 'api_service.dart';

class AddressService {
  static Future<List<dynamic>> getProvinsi() async {
    final response = await ApiService.get('${Env.baseUrl}/region/provinsi');
    return response['data'] ?? [];
  }

  static Future<List<dynamic>> getKabupaten(int provinsiId) async {
    final response = await ApiService.get('${Env.baseUrl}/region/kabupaten/$provinsiId');
    return response['data'] ?? [];
  }

  static Future<List<dynamic>> getKecamatan(int kabupatenId) async {
    final response = await ApiService.get('${Env.baseUrl}/region/kecamatan/$kabupatenId');
    return response['data'] ?? [];
  }

  static Future<List<dynamic>> getDesa(int kecamatanId) async {
    final response = await ApiService.get('${Env.baseUrl}/region/desa/$kecamatanId');
    return response['data'] ?? [];
  }

  static Future<Map<String, dynamic>> saveAddress(
    Map<String, dynamic> data
    ) async {
    return await ApiService.post(
        '${Env.baseUrl}/addresses', 
      data
    );
  }

  static Future<Map<String, dynamic>> getAddress(
    Map<String, dynamic> data
    ) async {
    return await ApiService.get(
        '${Env.baseUrl}/addresses/{id}', 
      data
    );
  }

  static Future<Map<String, dynamic>> updateAddress(
    Map<String, dynamic> data
    ) async {
    return await ApiService.post(
        '${Env.baseUrl}/addresses', 
      data
    );
  }
}
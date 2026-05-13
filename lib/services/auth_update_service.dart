import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';
import '../config/env.dart';

class AuthUpdateService {

  // ── Ubah Password via Firebase ────────────────────────
  static Future<Map<String, dynamic>> changePassword(
    String newPassword,
    String confirmPassword,
  ) async {
    if (newPassword != confirmPassword) {
      return {'success': false, 'message': 'Password tidak cocok'};
    }
    if (newPassword.length < 6) {
      return {'success': false, 'message': 'Password minimal 6 karakter'};
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User tidak ditemukan'};
      }

      // Update password di Firebase
      await user.updatePassword(newPassword);

      return {'success': true, 'message': 'Password berhasil diubah'};
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          return {
            'success': false,
            'message': 'Sesi expired, silakan login ulang'
          };
        case 'weak-password':
          return {
            'success': false,
            'message': 'Password terlalu lemah'
          };
        default:
          return {'success': false, 'message': e.message ?? 'Gagal ubah password'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── Ubah Email via Firebase ───────────────────────────
  static Future<Map<String, dynamic>> changeEmail(String newEmail) async {
    if (newEmail.isEmpty) {
      return {'success': false, 'message': 'Email tidak boleh kosong'};
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User tidak ditemukan'};
      }

      // Update email di Firebase
      await user.verifyBeforeUpdateEmail(newEmail);

      return {
        'success': true,
        'message': 'Email verifikasi dikirim ke $newEmail. Silakan cek email.'
      };
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return {'success': false, 'message': 'Format email tidak valid'};
        case 'email-already-in-use':
          return {'success': false, 'message': 'Email sudah digunakan'};
        case 'requires-recent-login':
          return {
            'success': false,
            'message': 'Sesi expired, silakan login ulang'
          };
        default:
          return {'success': false, 'message': e.message ?? 'Gagal ubah email'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── Forgot Password via Laravel API ──────────────────
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await ApiService.post(
      '${Env.baseUrl}/auth/forgot-password',
      {'email': email},
    );
  }

  // ── Reset Password via Laravel API ───────────────────
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await ApiService.post(
      '${Env.baseUrl}/auth/reset-password',
      {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }
}
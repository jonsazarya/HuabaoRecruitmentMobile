import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/env.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ── Login Email 
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseToken = await credential.user?.getIdToken(true);

      debugPrint('=== FIREBASE TOKEN ===');
      debugPrint(firebaseToken);
      debugPrint('TOKEN LENGTH: ${firebaseToken?.length}');
      debugPrint('======================');

      if (firebaseToken == null) {
        return {'success': false, 'message': 'Firebase token gagal'};
      }

      // Langsung hit API tanpa ApiService agar response tidak dibungkus
      final response = await _postDirect(
        '${Env.baseUrl}/auth/firebase-login',
        {
          'firebase_uid': credential.user?.uid,
          'email': credential.user?.email,
        },
      );

      debugPrint('Firebase Login Response: $response');

      if (response['success'] == true) {
        await _saveUserData(
          firebaseToken: firebaseToken,
          backendToken: response['token'] ?? '',
          userData: response['user'],
          uid: credential.user?.uid ?? '',
        );
      }

      return response;
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _firebaseError(e.code)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── Register 
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String ktp,
    required String phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      final firebaseToken = await credential.user?.getIdToken();

      final response = await _postDirect(
        '${Env.baseUrl}/auth/register',
        {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'ktp': ktp,
          'phone': phone,
          'firebase_token': firebaseToken,
        },
      );

      debugPrint('Register Response: $response');

      if (response['success'] == true) {
        await _saveUserData(
          firebaseToken: firebaseToken ?? '',
          backendToken: response['token'] ?? '',
          userData: response['user'] ?? response['data'],
          uid: credential.user?.uid ?? '',
        );
      }

      return response;
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _firebaseError(e.code)};
    } catch (e) {
      return {'success': false, 'message': 'Register gagal: $e'};
    }
  }

  // ── Google Login 
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Login dibatalkan'};
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseToken = await userCredential.user?.getIdToken();

      if (firebaseToken == null) {
        return {'success': false, 'message': 'Firebase token gagal'};
      }

      final response = await _postDirect(
        '${Env.baseUrl}/auth/firebase-login',
        {'idToken': firebaseToken},
      );

      debugPrint('Google Login Response: $response');

      if (response['success'] == true) {
        await _saveUserData(
          firebaseToken: firebaseToken,
          backendToken: response['token'] ?? '',
          userData: response['user'],
          uid: userCredential.user?.uid ?? '',
        );
      }

      return response;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── Logout 
  static Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Get Backend Token 
  static Future<String?> getBackendToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('backend_token');
  }

  // ── Get User Data 
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data') ?? '{}';
    try {
      return jsonDecode(userDataString);
    } catch (e) {
      return {};
    }
  }

  // ── Save User Data 
  static Future<void> _saveUserData({
    required String firebaseToken,
    required String backendToken,
    required dynamic userData,
    required String uid,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('firebase_token', firebaseToken);
    await prefs.setString('backend_token', backendToken);
    await prefs.setString('uid', uid);

    if (userData != null) {
      await prefs.setString('user_data', jsonEncode(userData));
      await prefs.setString('user_id', userData['id']?.toString() ?? '');
      await prefs.setString('name', userData['name']?.toString() ?? '');
      await prefs.setString('email', userData['email']?.toString() ?? '');
    }

    // Verifikasi tersimpan
    debugPrint('=== SAVED USER DATA ===');
    debugPrint('backend_token: $backendToken');
    debugPrint('user_id: ${userData?['id']}');
    debugPrint('name: ${userData?['name']}');
    debugPrint('=======================');
  }

  // Post langsung tanpa ApiService wrapper
  // Digunakan untuk auth agar response tidak dibungkus
  static Future<Map<String, dynamic>> _postDirect(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      debugPrint('URL: $url');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── Firebase Error Messages ───────────────────────────
  static String _firebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'User tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'invalid-email':
        return 'Email tidak valid';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan';
      default:
        return 'Terjadi kesalahan';
    }
  }
}
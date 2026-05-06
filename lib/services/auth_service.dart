import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static const String baseUrl = 'http://10.24.172.60:8000/api';

  // ── Status User ──────────────────────────────────────
  static User? getCurrentUser() => _auth.currentUser;
  static bool isLoggedIn() => _auth.currentUser != null;

  // ── Login Email ──────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseToken = await credential.user?.getIdToken();
      if (firebaseToken == null) return {'success': false, 'message': 'Token gagal'};

      final backendResponse = await sendTokenToBackend(firebaseToken);
      if (backendResponse['success'] != true) return backendResponse;

      // UPDATE: Kirim backendResponse['user'] ke fungsi save
      await _saveUserData(
        firebaseToken: firebaseToken,
        backendToken: backendResponse['token'] ?? '',
        userFromBackend: backendResponse['user'], 
        uid: credential.user?.uid ?? '',
      );

      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── Register ─────────────────────────────────────────
  static Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password,
      String ktp,
      String phone) async {
    try {
      // 1. Register ke Firebase
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      final firebaseToken = await credential.user?.getIdToken();

      // 2. Register ke Laravel
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'ktp': ktp,
          'phone': phone,
          'firebase_token': firebaseToken,
        }),
      );

      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        await _saveUserData(
          firebaseToken: firebaseToken ?? '',
          backendToken: result['token'] ?? '',
          userFromBackend: result['user'],
          uid: credential.user?.uid ?? '',
        );
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Google Sign-In gagal: $e'};
    }
  }

  // ── Google Sign In ────────────────────────────────────
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
        return {'success': false, 'message': 'Token Firebase gagal dibuat'};
      }

      final backendResponse = await sendTokenToBackend(firebaseToken);
      if (backendResponse['success'] == true) {
        await _saveUserData(
          firebaseToken: firebaseToken,
          backendToken: backendResponse['token'] ?? '',
          userFromBackend: backendResponse['user'],
          uid: userCredential.user?.uid ?? '',
        );
        return {'success': true};
      }
      return {'success': false, 'message': 'Backend login gagal'};
      } catch (e) {
      return {'success': false, 'message': 'Google Sign-In gagal: $e'};
    }
  }

  // ── Logout ────────────────────────────────────────────
  static Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Forgot Password ───────────────────────────────────
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── Send Firebase Token ke Backend ───────────────────
  static Future<Map<String, dynamic>> sendTokenToBackend(
      String firebaseToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/firebase-login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'idToken': firebaseToken}),
      );

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Server error'
        };
      }
    } catch (e) {
      print('ERROR sendTokenToBackend: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── Get Backend Token ─────────────────────────────────
  static Future<String?> getBackendToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('backend_token');
  }

  // ── Get User Data ─────────────────────────────────────
  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name') ?? '',
      'email': prefs.getString('email') ?? '',
      'photo_url': prefs.getString('photo_url') ?? '',
      'uid': prefs.getString('uid') ?? '',
    };
  }

  // ── Save User Data ────────────────────────────────────
  static Future<void> _saveUserData({
    required String firebaseToken,
    required String backendToken,
    required dynamic userFromBackend,
    required String uid,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('firebase_token', firebaseToken);
    await prefs.setString('backend_token', backendToken);
    await prefs.setString('uid', uid);

    if (userFromBackend != null) {
      await prefs.setString('user_data', jsonEncode(userFromBackend));
      await prefs.setString('name', userFromBackend['name'] ?? '');
      await prefs.setString('email', userFromBackend['email'] ?? '');
    } else {
      await prefs.setString('user_data', '{}'); 
    }
  }

  // ── Error Messages ────────────────────────────────────
  static String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      default:
        return 'Terjadi kesalahan';
    }
  }
}
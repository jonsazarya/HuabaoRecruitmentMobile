import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Cek apakah user sudah login
  static User? getCurrentUser() => _auth.currentUser;
  static bool isLoggedIn() => _auth.currentUser != null;

  // ── Login Email & Password ───────────────────────────
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final token = await credential.user?.getIdToken();
      await _saveUserData(
        token: token ?? '',
        uid: credential.user?.uid ?? '',
        name: credential.user?.displayName ?? '',
        email: credential.user?.email ?? '',
      );

      return {'success': true, 'token': token};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  // ── Register Email & Password ────────────────────────
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(name);
      final token = await credential.user?.getIdToken();
      await _saveUserData(
        token: token ?? '',
        uid: credential.user?.uid ?? '',
        name: name,
        email: email,
      );

      return {'success': true, 'token': token};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  // ── Login dengan Google ──────────────────────────────
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Tampilkan popup pilih akun Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User membatalkan
      if (googleUser == null) {
        return {'success': false, 'message': 'Login dibatalkan'};
      }

      // Ambil auth details dari Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Buat credential Firebase dari Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login ke Firebase dengan Google credential
      final userCredential =
          await _auth.signInWithCredential(credential);

      final token = await userCredential.user?.getIdToken();
      await _saveUserData(
        token: token ?? '',
        uid: userCredential.user?.uid ?? '',
        name: userCredential.user?.displayName ?? '',
        email: userCredential.user?.email ?? '',
        photoUrl: userCredential.user?.photoURL ?? '',
      );

      return {
        'success': true,
        'token': token,
        'uid': userCredential.user?.uid,
        'name': userCredential.user?.displayName,
        'email': userCredential.user?.email,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'Google Sign-In gagal: ${e.toString()}'
      };
    }
  }

  // ── Logout ───────────────────────────────────────────
  static Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Lupa Password ────────────────────────────────────
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    }
  }

  // ── Simpan data user ke SharedPreferences ────────────
  static Future<void> _saveUserData({
    required String token,
    required String uid,
    required String name,
    required String email,
    String photoUrl = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firebase_token', token);
    await prefs.setString('uid', uid);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('photo_url', photoUrl);
  }

  // ── Ambil data user dari SharedPreferences ───────────
  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name') ?? '',
      'email': prefs.getString('email') ?? '',
      'photo_url': prefs.getString('photo_url') ?? '',
      'uid': prefs.getString('uid') ?? '',
    };
  }

  // ── Pesan error Bahasa Indonesia ─────────────────────
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
        return 'Terjadi kesalahan, coba lagi';
    }
  }
}
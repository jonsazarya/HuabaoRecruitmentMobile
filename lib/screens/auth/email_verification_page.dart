import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:recruitment_mobile/config/env.dart';
import 'package:recruitment_mobile/screens/auth/login_page.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isResending = false;
  bool _isVerified  = false;
  String? _statusMsg;

  late final AppLinks _appLinks;
  StreamSubscription? _linkSub;

  @override
  void initState() {
    super.initState();
    _listenDeepLink();
    _checkAlreadyVerified();
    
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      debugPrint('=== POLLING CEK VERIFIED ===');
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('User null, cancel timer');
        timer.cancel();
        return;
      }
      await user.reload();
      final verified = FirebaseAuth.instance.currentUser?.emailVerified;
      debugPrint('emailVerified: $verified');
      if (verified == true) {
        timer.cancel();
        _onVerifiedSuccess();
      }
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _checkAlreadyVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await user.reload();
    if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
      _onVerifiedSuccess();
    }
  }

  void _listenDeepLink() {
    _appLinks = AppLinks();
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'recruitmentapp' && uri.host == 'verify-email') {
        final status = uri.queryParameters['status'];
        switch (status) {
          case 'success':
          case 'already-verified':
            _onVerifiedSuccess();
            break;
          case 'invalid-signature':
            setState(() => _statusMsg = 'Link verifikasi sudah kadaluarsa.');
            break;
          case 'user-not-found':
            setState(() => _statusMsg = 'Akun tidak ditemukan.');
            break;
          default:
            setState(() => _statusMsg = 'Link verifikasi tidak valid.');
        }
      }
    });
  }

  Future<void> _onVerifiedSuccess() async {
    await FirebaseAuth.instance.currentUser?.reload();

    if (!mounted) return;
    setState(() => _isVerified = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('backend_token') ?? '';

      final response = await http.post(
        Uri.parse('${Env.baseUrl}/email/resend'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final result = jsonDecode(response.body);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Email terkirim'),
          backgroundColor:
              result['success'] == true ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim ulang: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: _isVerified
                      ? Colors.green.withOpacity(0.1)
                      : const Color.fromRGBO(29, 93, 155, 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isVerified
                      ? Icons.check_circle_outline
                      : Icons.mark_email_unread_outlined,
                  size: 48,
                  color: _isVerified
                      ? Colors.green
                      : const Color.fromRGBO(29, 93, 155, 1),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                _isVerified ? 'Email Terverifikasi!' : 'Verifikasi Email Anda',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                _isVerified
                  ? 'Akun Anda berhasil diverifikasi.\nSilakan login untuk melanjutkan.'
                  : 'Kami telah mengirim link verifikasi ke:\n${widget.email}...',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              // Pesan error jika link tidak valid
              if (_statusMsg != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _statusMsg!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              if (!_isVerified) ...[
                // Tombol kirim ulang
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isResending ? null : _resendEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isResending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Kirim Ulang Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Kembali ke login
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!mounted) return;
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text(
                    'Kembali ke Login',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],

              // Loading indicator saat verified & redirect
              if (_isVerified) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(
                  color: Color.fromRGBO(29, 93, 155, 1),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
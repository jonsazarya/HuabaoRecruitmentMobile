import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recruitment_mobile/services/personal_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Opacity(
        opacity: _animation.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── PROFILE PAGE ───────────────────────────

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? _user = FirebaseAuth.instance.currentUser;

  Map<String, dynamic>? personalData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPersonalData();
  }

  Future<void> _loadPersonalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');

      if (userJson == null) {
        setState(() => _isLoading = false);
        return;
      }

      final userData = jsonDecode(userJson);
      final int userId = userData['id'];

      final result = await PersonalService.getPersonalByUserId(userId);

      if (result['success'] == true) {
        setState(() {
          personalData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error load profile: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: _isLoading ? _buildSkeleton() : _buildContent(),
    );
  }

  // ─── SKELETON ───
  Widget _buildSkeleton() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Stack(
            children: [
              Container(
                height: 300,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(29, 93, 155, 1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/huabao-logo.png',
                            width: 42,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Profil',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                      const SizedBox(height: 28),
                      // Profile card skeleton
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Name
                            _SkeletonBox(width: 150, height: 20, borderRadius: 6),
                            const SizedBox(height: 8),
                            // Email
                            _SkeletonBox(width: 200, height: 13, borderRadius: 6),
                            const SizedBox(height: 14),
                            // Status badge
                            _SkeletonBox(width: 100, height: 28, borderRadius: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Section + items skeleton (Informasi Akun)
          _buildSkeletonSection(3),
          const SizedBox(height: 8),

          // Informasi Pribadi
          _buildSkeletonSection(9),
          const SizedBox(height: 8),

          // Sosial Media
          _buildSkeletonSection(3),
          const SizedBox(height: 8),

          // Status Lamaran
          _buildSkeletonSectionLabel(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (_) => Column(
                  children: [
                    _SkeletonBox(width: 36, height: 24, borderRadius: 6),
                    const SizedBox(height: 6),
                    _SkeletonBox(width: 48, height: 11, borderRadius: 4),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSkeletonSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: _SkeletonBox(width: 120, height: 14, borderRadius: 6),
    );
  }

  Widget _buildSkeletonSection(int itemCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSkeletonSectionLabel(),
        ...List.generate(itemCount, (_) => _buildSkeletonInfoItem()),
      ],
    );
  }

  Widget _buildSkeletonInfoItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonBox(width: 60, height: 11, borderRadius: 4),
              const SizedBox(height: 6),
              _SkeletonBox(width: 140, height: 14, borderRadius: 6),
            ],
          ),
        ],
      ),
    );
  }

  // ─── REAL CONTENT ───
  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 300,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(29, 93, 155, 1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/huabao-logo.png',
                            width: 42,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Profil',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: _user?.photoURL != null
                                    ? ClipOval(
                                        child: Image.network(
                                          _user!.photoURL!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Image.asset(
                                        _getProfileImage(
                                          personalData?['gender'],
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            Text(
                              _user?.displayName ??
                                  personalData?['name'] ??
                                  'Pengguna',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              personalData?['email'] ?? _user?.email ?? '-',
                              style: const TextStyle(
                                color: Color.fromARGB(179, 0, 0, 0),
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 14),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 117, 117, 117)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                personalData?['status'] ?? 'Pelamar Aktif',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          _buildSectionTitle('Informasi Akun'),
          _buildInfoItem(Icons.email_outlined, 'Email',
              personalData?['email'] ?? _user?.email ?? '-'),
          _buildInfoItem(
            Icons.verified_outlined,
            'Status Email',
            _user?.emailVerified == true
                ? 'Sudah Terverifikasi ✓'
                : 'Belum Terverifikasi',
          ),
          _buildInfoItem(
              Icons.login_outlined, 'Login Dengan', _getLoginProvider()),

          const SizedBox(height: 8),

          _buildSectionTitle('Informasi Pribadi'),
          _buildInfoItem(
              Icons.badge_outlined, 'NIK', personalData?['ktp'] ?? '-'),
          _buildInfoItem(
            Icons.phone_outlined,
            'No. Telepon',
            personalData?['phone'] ?? personalData?['no_wa'] ?? '-',
          ),
          _buildInfoItem(Icons.location_city_outlined, 'Tempat Lahir',
              personalData?['birth_place'] ?? '-'),
          _buildInfoItem(Icons.cake_outlined, 'Tanggal Lahir',
              _formatDate(personalData?['birth_date'])),
          _buildInfoItem(Icons.person_outline, 'Jenis Kelamin',
              personalData?['gender'] ?? '-'),
          _buildInfoItem(Icons.favorite_outline, 'Status Pernikahan',
              personalData?['marital_status'] ?? '-'),
          _buildInfoItem(Icons.school_outlined, 'Pendidikan',
              personalData?['education_stage'] ?? '-'),
          _buildInfoItem(Icons.menu_book_outlined, 'Jurusan',
              personalData?['education_major'] ?? '-'),
          _buildInfoItem(Icons.account_balance_outlined, 'Instansi Pendidikan',
              personalData?['education_instansi'] ?? '-'),
          _buildInfoItem(Icons.account_balance_wallet_outlined, 'NPWP',
              personalData?['npwp'] ?? '-'),
          _buildInfoItem(Icons.health_and_safety_outlined, 'BPJS Kesehatan',
              personalData?['bpjs_kesehatan'] ?? '-'),
          _buildInfoItem(Icons.work_outline, 'BPJS Ketenagakerjaan',
              personalData?['bpjs_ketenagakerjaan'] ?? '-'),

          const SizedBox(height: 8),

          _buildSectionTitle('Sosial Media'),
          _buildInfoItem(Icons.camera_alt_outlined, 'Instagram',
              personalData?['instagram'] ?? '-'),
          _buildInfoItem(Icons.business_center_outlined, 'LinkedIn',
              personalData?['linkedin'] ?? '-'),
          _buildInfoItem(Icons.facebook_outlined, 'Facebook',
              personalData?['facebook'] ?? '-'),

          const SizedBox(height: 8),

          _buildSectionTitle('Status Lamaran'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusCount('Diajukan', '0', Colors.blue),
                _buildStatusCount('Proses', '0', Colors.orange),
                _buildStatusCount('Diterima', '0', Colors.green),
                _buildStatusCount('Ditolak', '0', Colors.red),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  String _getLoginProvider() {
    if (_user == null) return '-';
    final providers = _user!.providerData;
    if (providers.isEmpty) return '-';
    switch (providers.first.providerId) {
      case 'google.com':
        return 'Google';
      case 'password':
        return 'Email & Password';
      default:
        return providers.first.providerId;
    }
  }

  String _getProfileImage(String? gender) {
    if (gender == null) return 'assets/images/man_icon.png';
    final g = gender.toLowerCase();
    if (g.contains('perempuan')) return 'assets/images/woman_icon.png';
    return 'assets/images/man_icon.png';
  }

  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return '-';
    try {
      return date.toString().split('T')[0];
    } catch (e) {
      return date.toString();
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(29, 93, 155, 1),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(29, 93, 155, 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color.fromRGBO(29, 93, 155, 1),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCount(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
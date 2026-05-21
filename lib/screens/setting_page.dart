import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recruitment_mobile/services/auth_service.dart';
import 'package:recruitment_mobile/screens/auth/login_page.dart';
import 'package:recruitment_mobile/screens/settings/edit_profile_page.dart';
import 'package:recruitment_mobile/screens/settings/change_password_page.dart';
import 'package:recruitment_mobile/screens/settings/change_email_page.dart';
import 'package:recruitment_mobile/screens/settings/notification_page.dart';
import 'package:recruitment_mobile/screens/settings/language_page.dart';
import 'package:recruitment_mobile/screens/settings/about_app_page.dart';
import 'package:recruitment_mobile/screens/settings/help_page.dart';
import 'package:recruitment_mobile/screens/settings/privacy_policy_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

// SKELETON WIDGET 

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

// SETTING PAGE 

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isLoading = false);
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER 
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(29, 93, 155, 1),
              ),
              child: Row(
                children: [
                  Image.asset('assets/images/huabao-logo.png', width: 42),
                  const SizedBox(width: 10),
                  const Text(
                    'Pengaturan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
            ),

            const SizedBox(height: 8),

            _isLoading ? _buildSkeleton() : _buildContent(context),
          ],
        ),
      ),
    );
  }

  // SKELETON 
  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          _buildSkeletonSectionLabel(),
          _buildSkeletonItem(),
          _buildSkeletonItem(),

          const SizedBox(height: 8),

          _buildSkeletonSectionLabel(),
          _buildSkeletonItem(),
          _buildSkeletonItem(),

          const SizedBox(height: 8),

          _buildSkeletonSectionLabel(),
          _buildSkeletonItem(),
          _buildSkeletonItem(),
          _buildSkeletonItem(),

          const SizedBox(height: 24),

          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSkeletonSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: _SkeletonBox(width: 80, height: 14, borderRadius: 6),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          _SkeletonBox(width: 120, height: 14, borderRadius: 6),
          const Spacer(),
          _SkeletonBox(width: 20, height: 20, borderRadius: 4),
        ],
      ),
    );
  }

  // REAL CONTENT 
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECTION AKUN 
        _buildSectionTitle('Akun'),
        _buildSettingItem(
          context,
          Icons.person_outline,
          'Edit Profil',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfilePage()),
          ),
        ),
        _buildSettingItem(
          context,
          Icons.lock_outline,
          'Ubah Password',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
          ),
        ),

        const SizedBox(height: 8),

        // SECTION APLIKASI 
        _buildSectionTitle('Aplikasi'),
        _buildSettingItem(
          context,
          Icons.notifications_outlined,
          'Notifikasi',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationPage()),
          ),
        ),
        _buildSettingItem(
          context,
          Icons.language_outlined,
          'Bahasa',
          trailing: 'Indonesia',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LanguagePage()),
          ),
        ),

        const SizedBox(height: 8),

        // SECTION LAINNYA
        _buildSectionTitle('Lainnya'),
        _buildSettingItem(
          context,
          Icons.info_outline,
          'Tentang Aplikasi',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutAppPage()),
          ),
        ),
        _buildSettingItem(
          context,
          Icons.help_outline,
          'Bantuan',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpPage()),
          ),
        ),
        _buildSettingItem(
          context,
          Icons.privacy_tip_outlined,
          'Kebijakan Privasi',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
          ),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout),
              label: const Text(
                'Keluar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title, {
    String? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(29, 93, 155, 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color.fromRGBO(29, 93, 155, 1),
            size: 20,
          ),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: trailing != null
            ? Text(
                trailing,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              )
            : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
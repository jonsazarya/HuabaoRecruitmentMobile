import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recruitment_mobile/screens/settings/edit_profile_page.dart';
import 'package:recruitment_mobile/screens/settings/change_password_page.dart';
import 'package:recruitment_mobile/screens/settings/change_email_page.dart';
import 'package:recruitment_mobile/screens/settings/notification_page.dart';
import 'package:recruitment_mobile/screens/settings/language_page.dart';
import 'package:recruitment_mobile/screens/settings/about_app_page.dart';
import 'package:recruitment_mobile/screens/settings/help_page.dart';
import 'package:recruitment_mobile/screens/settings/privacy_policy_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── HEADER ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(29, 93, 155, 1),
            ),
            child: Row(
              children: [
                Image.asset('assets/images/huabao-logo.png', width: 36),
                const SizedBox(width: 10),
                const Text(
                  'Pengaturan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── SECTION AKUN ──────────────────────────────────
          _buildSectionTitle('Akun'),
          _buildSettingItem(
            context,
            Icons.person_outline,
            'Edit Profil',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EditProfilePage())),
          ),
          _buildSettingItem(
            context,
            Icons.lock_outline,
            'Ubah Password',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
          ),
          _buildSettingItem(
            context,
            Icons.email_outlined,
            'Ubah Email',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChangeEmailPage())),
          ),

          const SizedBox(height: 8),

          // ── SECTION APLIKASI ──────────────────────────────
          _buildSectionTitle('Aplikasi'),
          _buildSettingItem(
            context,
            Icons.notifications_outlined,
            'Notifikasi',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationPage())),
          ),
          _buildSettingItem(
            context,
            Icons.language_outlined,
            'Bahasa',
            trailing: 'Indonesia',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LanguagePage())),
          ),

          const SizedBox(height: 8),

          // ── SECTION LAINNYA ───────────────────────────────
          _buildSectionTitle('Lainnya'),
          _buildSettingItem(
            context,
            Icons.info_outline,
            'Tentang Aplikasi',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutAppPage())),
          ),
          _buildSettingItem(
            context,
            Icons.help_outline,
            'Bantuan',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HelpPage())),
          ),
          _buildSettingItem(
            context,
            Icons.privacy_tip_outlined,
            'Kebijakan Privasi',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
          ),

          const SizedBox(height: 16),

          // ── TOMBOL LOGOUT ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  // nanti sambungkan ke logout API
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
                          onPressed: () {
                            Navigator.pop(ctx);
                            // Navigator.pushReplacement ke LoginPage
                          },
                          child: const Text(
                            'Keluar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
          child: Icon(icon,
              color: const Color.fromRGBO(29, 93, 155, 1), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: trailing != null
            ? Text(trailing,
                style: const TextStyle(color: Colors.grey, fontSize: 13))
            : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:recruitment_mobile/screens/registration_forms/data_diri_page.dart';
import 'package:recruitment_mobile/screens/registration_forms/data_keluarga_page.dart';
import 'package:recruitment_mobile/screens/registration_forms/data_peminatan_page.dart';
import 'package:recruitment_mobile/screens/registration_forms/data_bpjs_page.dart';
import 'package:recruitment_mobile/screens/registration_forms/data_pengalaman_kerja_page.dart';
import 'package:recruitment_mobile/screens/registration_forms/data_kursus_page.dart';
import 'package:recruitment_mobile/screens/registration_forms/data_kontak_page.dart';
import 'package:recruitment_mobile/screens/registration_forms/data_alamat_page.dart';

class RegistrationFormPage extends StatelessWidget {
  const RegistrationFormPage({super.key});

  static const List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.person_outline, 'title': 'Data Diri'},
    {'icon': Icons.people_outline, 'title': 'Data Keluarga'},
    {'icon': Icons.bookmark_border, 'title': 'Data Peminatan'},
    {'icon': Icons.medical_information_outlined, 'title': 'Data BPJS'},
    {'icon': Icons.work_history_outlined, 'title': 'Data Pengalaman Kerja'},
    {'icon': Icons.school_outlined, 'title': 'Data Kursus / Pelatihan / Sertifikasi'},
    {'icon': Icons.phone_outlined, 'title': 'Data Kontak'},
    {'icon': Icons.location_on_outlined, 'title': 'Data Alamat'},
  ];

  static const List<Widget> _pages = [
    DataDiriPage(),
    DataKeluargaPage(),
    DataPeminatanPage(),
    DataBpjsPage(),
    DataPengalamanKerjaPage(),
    DataKursusPage(),
    DataKontakPage(),
    DataAlamatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Form Registrasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _menuItems.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(
                item['icon'] as IconData,
                color: const Color.fromRGBO(29, 93, 155, 1),
              ),
              title: Text(
                item['title'] as String,
                style: const TextStyle(fontSize: 14),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => _pages[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
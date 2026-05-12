import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Kebijakan Privasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kebijakan Privasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(29, 93, 155, 1),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Terakhir diperbarui: Januari 2026',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                '1. Informasi yang Kami Kumpulkan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Kami mengumpulkan informasi yang Anda berikan secara langsung, seperti nama, email, dan data pribadi lainnya saat mendaftar.',
                style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                '2. Penggunaan Informasi',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Informasi yang dikumpulkan digunakan untuk memproses lamaran kerja dan berkomunikasi dengan pelamar.',
                style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                '3. Keamanan Data',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Kami berkomitmen untuk melindungi data pribadi Anda dengan menggunakan enkripsi dan langkah keamanan yang sesuai.',
                style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                '4. Hubungi Kami',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Jika ada pertanyaan mengenai kebijakan privasi ini, silakan hubungi kami melalui menu Pelayanan.',
                style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
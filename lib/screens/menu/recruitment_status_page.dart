import 'package:flutter/material.dart';

class RecruitmentStatusPage extends StatelessWidget {
  const RecruitmentStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Status Perekrutan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text('Status proses lamaran : ',
                    style: TextStyle(fontSize: 14)),
                Text(
                  'Jones Azarya',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(29, 93, 155, 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTimelineItem(
              tanggal: '28 Jan 2026',
              judul: 'Aktivasi Akun',
              deskripsi: 'Aktivasi akun berhasil dilakukan.',
              isDone: true,
              isLast: false,
            ),
            _buildTimelineItem(
              tanggal: '28 Jan 2026',
              judul: 'Registrasi Akun',
              deskripsi: 'Registrasi akun berhasil dilakukan.',
              isDone: true,
              isLast: false,
            ),
            _buildTimelineItem(
              tanggal: '',
              judul: 'Menunggu',
              deskripsi: 'Menunggu proses selanjutnya.',
              isDone: false,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String tanggal,
    required String judul,
    required String deskripsi,
    required bool isDone,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (tanggal.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(29, 93, 155, 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tanggal,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              )
            else
              const SizedBox(height: 22),
            const SizedBox(height: 4),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone
                    ? const Color.fromRGBO(29, 93, 155, 1)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check : Icons.access_time,
                color: Colors.white,
                size: 14,
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 70, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(deskripsi,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
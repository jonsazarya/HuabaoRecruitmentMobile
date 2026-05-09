import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recruitment_mobile/services/personal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recruitment_mobile/services/api_service.dart';

class DataDiriPage extends StatefulWidget {
  const DataDiriPage({super.key});

  @override
  State<DataDiriPage> createState() => _DataDiriPageState();
}

class _DataDiriPageState extends State<DataDiriPage> {
  final _namaController = TextEditingController();
  final _ktpController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _nomorAK1Controller = TextEditingController();
  final _jurusanController = TextEditingController();
  final _asalSekolahController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _ktpController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _nomorAK1Controller.dispose();
    _jurusanController.dispose();
    _asalSekolahController.dispose();
    super.dispose();
  }

  String? _selectedAgama;
  String? _selectedJenisKelamin;
  String? _selectedStatusPernikahan;
  String? _selectedPendidikan;
  String? _selectedLokasiKerja;
  bool _isLoading = false;

  final List<String> _agamaOptions = [
    'Islam',
    'Kristen',
    'Katholik',
    'Hindu',
    'Budha',
    'Konghucu',
  ];
  final List<String> _jenisKelaminOptions = ['Laki-laki', 'Perempuan'];
  final List<String> _statusPernikahanOptions = [
    'Tidak Kawin',
    'Kawin Belum Tercatat',
    'Kawin Tercatat',
    'Cerai Hidup',
    'Cerai Mati',
  ];
  final List<String> _pendidikanOptions = [
    'SD/Paket A/MI',
    'SMP/Paket B/Mts',
    'SMA/SMK/Paket C/MA',
    'D1',
    'D2',
    'D3',
    'D4',
    'S1',
    'S2',
    'S3',
  ];
  final List<String> _lokasiKerjaOptions = [
    'Jakarta',
    'Morowali',
    'Dimana Saja',
  ];

  String _toIsoDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
      return date;
    } catch (e) {
      return date;
    }
  }

  Future<void> _simpan() async {
    //  Validasi Input Dasar
    if (_ktpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor KTP harus diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      //  Ambil ID User Lokal (Integer)
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('user_data');

      if (userJson == null) {
        throw Exception("Sesi user tidak ditemukan. Silakan login kembali.");
      }
      
      final userData = jsonDecode(userJson);
      final int localUserId = userData['id'];
      final email = FirebaseAuth.instance.currentUser?.email ?? '';

      // Kirim Data ke API
      final result = await PersonalService.createPersonal({
        'user_id': localUserId,
        'ktp': _ktpController.text,
        'status': 'Pelamar',
        'kk': '-',
        'gender': _selectedJenisKelamin ?? '-',
        'religion': _selectedAgama ?? '-',
        'birth_place': _tempatLahirController.text.isEmpty
            ? '-'
            : _tempatLahirController.text,
        'birth_date': _tanggalLahirController.text.isNotEmpty
            ? _toIsoDate(_tanggalLahirController.text)
            : null,
        'marital_status': _selectedStatusPernikahan ?? '-',
        'nomor_pencarikerja': _nomorAK1Controller.text,
        'education_stage': _selectedPendidikan ?? '-',
        'education_major': _jurusanController.text,
        'education_instansi': _asalSekolahController.text,
        'lokasi_kerja_yang_diharapkan': _selectedLokasiKerja ?? '-',
        'email': email,
        'has_experience': 'Tidak',
        'current_salary': 0,
        'expected_salary': 0,
        'phone': '-',
        'no_wa': '-',
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Cek Response
      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final personalId = result['data']?['id']?.toString() ?? '';
        if (personalId.isNotEmpty) {
          await prefs.setString('personal_id', personalId);

          final userDataString = prefs.getString('user_data') ?? '{}';
          final userData = jsonDecode(userDataString);
          userData['personal_id'] = personalId;
          await prefs.setString('user_data', jsonEncode(userData));

          debugPrint('Saved personal_id: $personalId');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data Diri berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        String errorMsg =
            result['message']?.toString() ?? 'Gagal menyimpan data';
        if (result['errors'] != null) {
          errorMsg = result['errors'].toString();
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Data Diri'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField('Nama Lengkap :', _namaController),
                  _buildField(
                    'Nomor KTP :',
                    _ktpController,
                    keyboardType: TextInputType.number,
                  ),
                  _buildDropdown(
                    label: 'Agama :',
                    value: _selectedAgama,
                    items: _agamaOptions,
                    onChanged: (v) => setState(() => _selectedAgama = v),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    label: 'Jenis Kelamin :',
                    value: _selectedJenisKelamin,
                    items: _jenisKelaminOptions,
                    onChanged: (v) => setState(() => _selectedJenisKelamin = v),
                  ),
                  const SizedBox(height: 12),
                  _buildField('Tempat Lahir :', _tempatLahirController),
                  _buildLabel('Tanggal Lahir :'),
                  const SizedBox(height: 4),
                  _buildDateField(_tanggalLahirController),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    label: 'Status Pernikahan :',
                    value: _selectedStatusPernikahan,
                    items: _statusPernikahanOptions,
                    onChanged: (v) =>
                        setState(() => _selectedStatusPernikahan = v),
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    'Nomor Pencari Kerja (AK 1) :',
                    _nomorAK1Controller,
                  ),
                  _buildDropdown(
                    label: 'Pendidikan Terakhir :',
                    value: _selectedPendidikan,
                    items: _pendidikanOptions,
                    onChanged: (v) => setState(() => _selectedPendidikan = v),
                  ),
                  const SizedBox(height: 12),
                  _buildField('Jurusan :', _jurusanController),
                  _buildField(
                    'Asal Sekolah/Universitas :',
                    _asalSekolahController,
                  ),
                  _buildDropdown(
                    label: 'Lokasi Kerja yang Diharapkan :',
                    value: _selectedLokasiKerja,
                    items: _lokasiKerjaOptions,
                    onChanged: (v) => setState(() => _selectedLokasiKerja = v),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _simpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'SIMPAN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // --- Widget Helpers ---
  Widget _buildLabel(String label) => Text(
    label,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
  );

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: onChanged,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, size: 20),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(
                  () => controller.text =
                      "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}",
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

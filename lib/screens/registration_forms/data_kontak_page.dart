import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recruitment_mobile/services/personal_service.dart';

class DataKontakPage extends StatefulWidget {
  const DataKontakPage({super.key});

  @override
  State<DataKontakPage> createState() => _DataKontakPageState();
}

class _DataKontakPageState extends State<DataKontakPage> {
  // Controller untuk Data Kontak
  final _waController = TextEditingController(); // Untuk no_wa
  final _phoneController = TextEditingController(); // Untuk phone
  final _facebookController = TextEditingController();
  final _linkedinController = TextEditingController();

  // Controller untuk Kontak Darurat
  final _namaKontakDaruratController = TextEditingController();
  final _noHpDaruratController = TextEditingController();

  String? _selectedHubungan;
  bool _isLoading = false;

  final List<String> _hubunganOptions = [
    'Orang Tua',
    'Suami/Istri',
    'Saudara',
    'Teman',
    'Lainnya',
  ];

  @override
  void dispose() {
    _waController.dispose();
    _phoneController.dispose();
    _facebookController.dispose();
    _linkedinController.dispose();
    _namaKontakDaruratController.dispose();
    _noHpDaruratController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      if (userJson == null) throw Exception("Sesi berakhir");

      final userData = jsonDecode(userJson);

      // Ambil personal_id seperti pada DataBpjsPage
      final int personalId =
          int.tryParse(userData['personal_id']?.toString() ?? '0') ?? 0;

      if (personalId == 0) {
        throw Exception("ID Personal tidak ditemukan. Silakan login ulang.");
      }

      // Mapping payload sesuai dengan kolom di tabel 'personal'
      final Map<String, dynamic> payload = {
        "user_id": userData['id'],
        "no_wa": _waController.text,
        "phone": _phoneController.text,
        "facebook": _facebookController.text,
        "linkedin": _linkedinController.text,
        "kontak_darurat_name": _namaKontakDaruratController.text,
        "kontak_darurat_hubungan": _selectedHubungan,
        "kontak_darurat_hp": _noHpDaruratController.text,
      };

      final result = await PersonalService.updatePersonal(personalId, payload);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data Kontak Berhasil Diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception(result['message'] ?? 'Gagal memperbarui data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Data Kontak'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField(
                    'Nomor WhatsApp (WA) :',
                    _waController,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildField(
                    'Nomor HP (Telepon) :',
                    _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildField('Facebook :', _facebookController),
                  _buildField('LinkedIn :', _linkedinController),

                  const SizedBox(height: 20),
                  const Text(
                    'Kontak Darurat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(29, 93, 155, 1),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildField(
                    'Nama Kontak Darurat :',
                    _namaKontakDaruratController,
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Hubungan :',
                          value: _selectedHubungan,
                          items: _hubunganOptions,
                          onChanged: (v) =>
                              setState(() => _selectedHubungan = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          'No. HP Darurat :',
                          _noHpDaruratController,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _simpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'SIMPAN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget Helper
  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

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
              hint: const Text(
                'Pilih',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 13)),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recruitment_mobile/services/certifications_service.dart'; // Sesuaikan path

class DataKursusPage extends StatefulWidget {
  const DataKursusPage({super.key});

  @override
  State<DataKursusPage> createState() => _DataKursusPageState();
}

class _DataKursusPageState extends State<DataKursusPage> {
  final _judulController = TextEditingController();
  final _penyelenggaraController = TextEditingController();
  final _durasiController = TextEditingController();
  final _tahunController = TextEditingController();

  @override
  void dispose() {
    _judulController.dispose();
    _penyelenggaraController.dispose();
    _durasiController.dispose();
    _tahunController.dispose();
    super.dispose();
  }

  String? _selectedKategori;
  bool _isLoading = false;

  final List<String> _kategoriOptions = [
    'Kursus', 
    'Pelatihan', 
    'Sertifikasi'
  ];

  Future<void> _simpan() async {
    if (_selectedKategori == null ||
        _judulController.text.trim().isEmpty ||
        _penyelenggaraController.text.trim().isEmpty ||
        _durasiController.text.trim().isEmpty ||
        _tahunController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field wajib diisi'),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      if (userJson == null) throw Exception("Sesi berakhir");

      final userData = jsonDecode(userJson);

      final Map<String, dynamic> payload = {
        "user_id": userData['id'].toString(),
        "kategori": _selectedKategori,
        "judul": _judulController.text,
        "penyelenggara": _penyelenggaraController.text,
        "durasi": _durasiController.text,
        "tahun": _tahunController.text,
      };

      final result = await CertificationsService.createCertifications(payload);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data Sertifikasi Berhasil Disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception(result['message'] ?? 'Gagal menyimpan data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Data Kursus / Pelatihan / Sertifikasi', style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdown(
                    label: 'Kategori :',
                    value: _selectedKategori,
                    items: _kategoriOptions,
                    onChanged: (v) => setState(() => _selectedKategori = v),
                  ),
                  const SizedBox(height: 12),
                  _buildField('Judul :', _judulController),
                  _buildField('Penyelenggara :', _penyelenggaraController),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField('Durasi :', _durasiController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        // Gunakan widget DateField agar konsisten dan valid
                        child: _buildDateField('Tahun :', _tahunController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _simpan,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      child: const Text(
                        'SIMPAN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500));
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
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
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // Di dalam DataKursusPage
  Widget _buildDateField(
    String label,
    TextEditingController controller, {
    bool disabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: disabled ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            readOnly: true,
            enabled: !disabled,
            style: const TextStyle(fontSize: 13),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1990),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color.fromRGBO(29, 93, 155, 1),
                    ),
                  ),
                  child: child!,
                ),
              );

              if (picked != null) {
                setState(
                  () => controller.text = picked.year.toString(), 
                );
              }
            },
            decoration: const InputDecoration(
              suffixIcon: Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              hint: const Text('Pilih Kategori',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: items
                  .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
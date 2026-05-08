import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:recruitment_mobile/services/families_service.dart';

class DataKeluargaPage extends StatefulWidget {
  const DataKeluargaPage({super.key});

  @override
  State<DataKeluargaPage> createState() => _DataKeluargaPageState();
}

class _DataKeluargaPageState extends State<DataKeluargaPage> {
  final _noKKController = TextEditingController();
  final _namaController = TextEditingController();
  final _noKTPController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();

  String? _selectedHubungan;
  String? _selectedJenisKelamin;

  bool _isLoading = false;

  final List<String> _hubunganOptions = [
    'Ayah', 'Ibu', 'Suami', 'Istri', 'Anak', 'Saudara', 'Lainnya'
  ];

  final List<String> _jenisKelaminOptions = [
    'Laki-laki',
    'Perempuan'
  ];

  Future<void> _simpan() async {
    if (_tanggalLahirController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal lahir wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      final userData = jsonDecode(userJson!);
      final int userId = userData['id'];
      
      // Konversi format tanggal dari DD/MM/YYYY ke YYYY-MM-DD
      final dateParts = _tanggalLahirController.text.split('/');
      final formattedDate = "${dateParts[2]}-${dateParts[1]}-${dateParts[0]}";

      final Map<String, dynamic> payload = {
        "user_id": userId,
        "name": _namaController.text,           
        "relationship": _selectedHubungan,     
        "gender": _selectedJenisKelamin,       
        "ktp": _noKTPController.text,         
        "birth_place": _tempatLahirController.text, 
        "birth_date": formattedDate,        
        "no_kk": _noKKController.text,
      };

      final result = await FamiliesService.createFamily(payload);

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data Keluarga berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        String errorMessage = result['message'] ?? 'Gagal menyimpan data';
        if (result['errors'] != null) {
          errorMessage = result['errors'].toString();
        }
        throw errorMessage;
      }
    } catch (e) {
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
        title: const Text('Data Keluarga'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _buildField('Nomor Kartu Keluarga (No.KK) :', _noKKController),
                  _buildField('Nama :', _namaController),

                  _buildDropdown(
                    label: 'Hubungan :',
                    value: _selectedHubungan,
                    items: _hubunganOptions,
                    onChanged: (v) => setState(() => _selectedHubungan = v),
                  ),
                  const SizedBox(height: 12),

                  _buildDropdown(
                    label: 'Jenis Kelamin :',
                    value: _selectedJenisKelamin,
                    items: _jenisKelaminOptions,
                    onChanged: (v) =>
                        setState(() => _selectedJenisKelamin = v),
                  ),
                  const SizedBox(height: 12),

                  _buildField('Nomor KTP :', _noKTPController),
                  _buildField('Tempat Lahir :', _tempatLahirController),

                  _buildLabel('Tanggal Lahir :'),
                  const SizedBox(height: 4),
                  _buildDateField(_tanggalLahirController),
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
                            horizontal: 24, vertical: 12),
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
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
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
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
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
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today_outlined,
                color: Colors.grey, size: 20),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );

              if (picked != null) {
                setState(() {
                  controller.text =
                      "${picked.day.toString().padLeft(2, '0')}/"
                      "${picked.month.toString().padLeft(2, '0')}/"
                      "${picked.year}";
                });
              }
            },
          ),
        ),
      ),
    );
  }
}
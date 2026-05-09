import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recruitment_mobile/services/personal_service.dart';

class DataPeminatanPage extends StatefulWidget {
  const DataPeminatanPage({super.key});

  @override
  State<DataPeminatanPage> createState() => _DataPeminatanPageState();
}

class _DataPeminatanPageState extends State<DataPeminatanPage> {
  final _gajiSaatIniController = TextEditingController();
  final _ekspektasiGajiController = TextEditingController();

  @override
  void dispose() {
    _gajiSaatIniController.dispose();
    _ekspektasiGajiController.dispose();
    super.dispose();
  }

  String? _selectedKategori;
  String? _selectedPosisi;

  bool _isLoading = false;

  final Map<String, int> _kategoriMap = {
    'Umum': 1,
    'Engineering': 2,
    'Penerjemah': 3,
  };

  final Map<String, int> _posisiMap = {
    'Helper Kantin': 1,
    'Operator DT': 2,
    'Driver Dutro': 3,
  };

  final List<String> _kategoriOptions = ['Umum', 'Engineering', 'Penerjemah'];
  final List<String> _posisiOptions = ['Helper Kantin', 'Operator DT', 'Driver Dutro'];

  Future<void> _simpan() async {
    if (_selectedKategori == null || _selectedPosisi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori dan posisi terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      if (userJson == null) throw Exception("Sesi berakhir");

      final userData = jsonDecode(userJson);
      
      // Ambil personal_id dan pastikan jadi int
      final int personalId = int.tryParse(userData['personal_id']?.toString() ?? '0') ?? 0;

      if (personalId == 0) {
        throw Exception("ID Personal tidak ditemukan. Silakan login ulang.");
      }

      final Map<String, dynamic> payload = {
        "user_id": userData['id'], 
        // Kirim ID (int) bukan teks agar tidak error SQL
        "kategori": _kategoriMap[_selectedKategori],
        "posisi_yang_dilamar": _posisiMap[_selectedPosisi],
        "current_salary": double.tryParse(_gajiSaatIniController.text.replaceAll('.', '')) ?? 0,
        "expected_salary": double.tryParse(_ekspektasiGajiController.text.replaceAll('.', '')) ?? 0,
      };

      // Kirim personalId sebagai int ke service
      final result = await PersonalService.updatePersonal(personalId, payload);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data Berhasil Disimpan'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        throw Exception(result['message']);
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Data Peminatan'),
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
                const SizedBox(height: 4),
                _buildDropdown(
                  label: 'Posisi Yang Dilamar :',
                  value: _selectedPosisi,
                  items: _posisiOptions,
                  onChanged: (v) => setState(() => _selectedPosisi = v),
                ),
                const SizedBox(height: 4),
                _buildField('Gaji Saat Ini :', _gajiSaatIniController, keyboardType: TextInputType.number),
                const SizedBox(height: 4),
                _buildField('Ekspektasi Gaji :', _ekspektasiGajiController, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
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
    return Text(label,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500));
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
        const SizedBox(height: 6),
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
              hint: const Text('',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Colors.grey),
              style: const TextStyle(
                  fontSize: 13, color: Colors.black87),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
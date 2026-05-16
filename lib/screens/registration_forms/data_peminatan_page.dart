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

  bool _isLoading = false;
  bool _isLoadingData = true;

  List<dynamic> _kategoriList = [];
  List<dynamic> _posisiList = [];

  int? _selectedKategoriId;
  int? _selectedPosisiId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _gajiSaatIniController.dispose();
    _ekspektasiGajiController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {

      debugPrint("=== LOAD DATA START ===");

      final kategoriResult =
          await PersonalService.getKategoriPosisi();

      final posisiResult =
          await PersonalService.getPosisi();

      debugPrint("=== HASIL API KATEGORI ===");
      debugPrint(kategoriResult.toString());

      debugPrint("=== HASIL API POSISI ===");
      debugPrint(posisiResult.toString());

      setState(() {
        _kategoriList = kategoriResult;
        _posisiList = posisiResult;
        _isLoadingData = false;
      });

      debugPrint("=== LIST SETELAH SETSTATE ===");

      debugPrint("Kategori List:");
      debugPrint(_kategoriList.toString());

      debugPrint("Posisi List:");
      debugPrint(_posisiList.toString());

      debugPrint(
        "Jumlah kategori: ${_kategoriList.length}",
      );

      debugPrint(
        "Jumlah posisi: ${_posisiList.length}",
      );

    } catch (e, stacktrace) {

      debugPrint('=== ERROR LOAD DATA ===');

      debugPrint(e.toString());

      debugPrint(stacktrace.toString());

      setState(() {
        _isLoadingData = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memuat data: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<dynamic> get _filteredPosisi {
    if (_selectedKategoriId == null) {
      return [];
    }

    return _posisiList.where((item) {
      return item['kategory_position_id'] == _selectedKategoriId;
    }).toList();
  }

  Future<void> _simpan() async {
    if (_selectedKategoriId == null ||
        _selectedPosisiId == null ||
        _gajiSaatIniController.text.trim().isEmpty ||
        _ekspektasiGajiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field wajib diisi'),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final userJson = prefs.getString('user_data');

      if (userJson == null) {
        throw Exception("Sesi berakhir");
      }

      final userData = jsonDecode(userJson);

      final int personalId =
          int.tryParse(userData['personal_id']?.toString() ?? '0') ?? 0;

      if (personalId == 0) {
        throw Exception("ID Personal tidak ditemukan");
      }

      final payload = {
        "user_id": userData['id'],
        "kategori": _selectedKategoriId,
        "posisi_yang_dilamar": _selectedPosisiId,
        "current_salary":
            double.tryParse(_gajiSaatIniController.text.replaceAll('.', '')) ??
            0,
        "expected_salary":
            double.tryParse(
              _ekspektasiGajiController.text.replaceAll('.', ''),
            ) ??
            0,
      };

      final result = await PersonalService.updatePersonal(personalId, payload);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        throw Exception(result['message'] ?? 'Gagal menyimpan data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Data Peminatan', style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),),
      ),

      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKategoriDropdown(),

                  const SizedBox(height: 16),

                  _buildPosisiDropdown(),

                  const SizedBox(height: 16),

                  _buildField(
                    'Gaji Saat Ini :',
                    _gajiSaatIniController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    'Ekspektasi Gaji :',
                    _ekspektasiGajiController,
                    keyboardType: TextInputType.number,
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
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

        const SizedBox(height: 6),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
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
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKategoriDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Kategori :'),

        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,

              value: _selectedKategoriId,

              hint: const Text(
                'Pilih kategori',
                style: TextStyle(fontSize: 13),
              ),

              items: _kategoriList.map((item) {

                debugPrint(
                  "Kategori Item: ${item.toString()}",
                );

                return DropdownMenuItem<int>(
                  value: item['id'],

                  child: Text(
                    item['kategory_position'],
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  _selectedKategoriId = value;
                  _selectedPosisiId = null;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPosisiDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Posisi Yang Dilamar :'),

        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,

              value: _selectedPosisiId,

              hint: const Text('Pilih posisi', style: TextStyle(fontSize: 13)),

              items: _filteredPosisi.map((item) {
                
                debugPrint(
                  "Posisi Item: ${item.toString()}",
                );

                return DropdownMenuItem<int>(
                  value: item['id'],

                  child: Text(
                    item['name'],
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),

              onChanged: _selectedKategoriId == null
                  ? null
                  : (value) {
                      setState(() {
                        _selectedPosisiId = value;
                      });
                    },
            ),
          ),
        ),
      ],
    );
  }
}

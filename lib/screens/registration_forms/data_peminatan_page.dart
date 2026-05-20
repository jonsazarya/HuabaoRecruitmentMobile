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
  final _gajiSaatIniController    = TextEditingController();
  final _ekspektasiGajiController = TextEditingController();

  bool _isLoading     = false;
  bool _isLoadingData = true;

  List<dynamic> _kategoriList = [];
  List<dynamic> _posisiList   = [];

  int? _selectedKategoriId;
  int? _selectedPosisiId;
  int? _personalId; // untuk UPDATE

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

  // ─── GET master data + data peminatan yang sudah tersimpan ───
  Future<void> _loadData() async {
    try {
      // 1. Load master data kategori & posisi
      final kategoriResult = await PersonalService.getKategoriPosisi();
      final posisiResult   = await PersonalService.getPosisi();

      // 2. Load data peminatan dari personal user
      final prefs    = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');

      if (userJson != null) {
        final userData  = jsonDecode(userJson);
        final userId    = userData['id'];

        final personalResult = await PersonalService.getPersonalByUserId(userId);

        if (personalResult['success'] == true && personalResult['data'] != null) {
          final data = personalResult['data'];

          _personalId = data['id'];

          // Isi gaji jika sudah ada
          final currentSalary  = data['current_salary'];
          final expectedSalary = data['expected_salary'];

          if (currentSalary != null && currentSalary.toString() != '0') {
            _gajiSaatIniController.text = currentSalary.toString();
          }
          if (expectedSalary != null && expectedSalary.toString() != '0') {
            _ekspektasiGajiController.text = expectedSalary.toString();
          }

          // Set dropdown kategori & posisi dari data tersimpan
          // (dilakukan setelah list tersedia)
          final savedKategoriId = data['kategori'];
          final savedPosisiId   = data['posisi_yang_dilamar'];

          setState(() {
            _kategoriList        = kategoriResult;
            _posisiList          = posisiResult;

            // Validasi: hanya set jika id ada di list
            if (savedKategoriId != null &&
                kategoriResult.any((k) => k['id'] == savedKategoriId)) {
              _selectedKategoriId = savedKategoriId;
            }

            if (savedPosisiId != null &&
                posisiResult.any((p) => p['id'] == savedPosisiId)) {
              _selectedPosisiId = savedPosisiId;
            }

            _isLoadingData = false;
          });

          return; // selesai, keluar dari _loadData
        }
      }

      // Jika belum ada data personal, tetap load master data saja
      setState(() {
        _kategoriList  = kategoriResult;
        _posisiList    = posisiResult;
        _isLoadingData = false;
      });
    } catch (e, stacktrace) {
      debugPrint('Error load data peminatan: $e');
      debugPrint(stacktrace.toString());

      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<dynamic> get _filteredPosisi {
    if (_selectedKategoriId == null) return [];
    return _posisiList
        .where((item) => item['kategory_position_id'] == _selectedKategoriId)
        .toList();
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

    setState(() => _isLoading = true);

    try {
      final prefs    = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');

      if (userJson == null) throw Exception('Sesi berakhir');

      final userData  = jsonDecode(userJson);
      final personalId = _personalId ??
          int.tryParse(userData['personal_id']?.toString() ?? '0') ?? 0;

      if (personalId == 0) throw Exception('ID Personal tidak ditemukan');

      final payload = {
        'user_id'              : userData['id'],
        'kategori'             : _selectedKategoriId,
        'posisi_yang_dilamar'  : _selectedPosisiId,
        'current_salary'       : double.tryParse(
              _gajiSaatIniController.text.replaceAll('.', ''),
            ) ?? 0,
        'expected_salary'      : double.tryParse(
              _ekspektasiGajiController.text.replaceAll('.', ''),
            ) ?? 0,
      };

      final result = await PersonalService.updatePersonal(personalId, payload);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data peminatan berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception(result['message'] ?? 'Gagal menyimpan data');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text(
          'Data Peminatan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
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

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  // ─── WIDGETS HELPER ───

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
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              hint: const Text('Pilih kategori', style: TextStyle(fontSize: 13)),
              items: _kategoriList.map((item) {
                return DropdownMenuItem<int>(
                  value: item['id'],
                  child: Text(
                    item['kategory_position'] ?? '-',
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKategoriId = value;
                  _selectedPosisiId   = null; // reset posisi saat kategori berubah
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
                return DropdownMenuItem<int>(
                  value: item['id'],
                  child: Text(
                    item['name'] ?? '-',
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: _selectedKategoriId == null
                  ? null
                  : (value) => setState(() => _selectedPosisiId = value),
            ),
          ),
        ),
      ],
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recruitment_mobile/services/personal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataDiriPage extends StatefulWidget {
  const DataDiriPage({super.key});

  @override
  State<DataDiriPage> createState() => _DataDiriPageState();
}

class _DataDiriPageState extends State<DataDiriPage> {
  final _namaController        = TextEditingController();
  final _ktpController         = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _nomorAK1Controller    = TextEditingController();
  final _jurusanController     = TextEditingController();
  final _asalSekolahController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingData = true;

  bool _isNamaDisabled = false;
  bool _isKtpDisabled = false;
  bool _hideNamaField = false;
  
  int? _personalId;

  String? _selectedAgama;
  String? _selectedJenisKelamin;
  String? _selectedStatusPernikahan;
  String? _selectedPendidikan;
  String? _selectedLokasiKerja;

  final List<String> _agamaOptions = [
    'Islam', 'Kristen', 'Katholik', 'Hindu', 'Budha', 'Konghucu',
  ];

  final List<String> _jenisKelaminOptions = ['Laki-laki', 'Perempuan'];

  final List<String> _statusPernikahanOptions = [
    'Tidak Kawin', 'Kawin Belum Tercatat', 'Kawin Tercatat',
    'Cerai Hidup', 'Cerai Mati',
  ];

  final List<String> _pendidikanOptions = [
    'SD/Paket A/MI', 'SMP/Paket B/Mts', 'SMA/SMK/Paket C/MA',
    'D1', 'D2', 'D3', 'D4', 'S1', 'S2', 'S3',
  ];

  final List<String> _lokasiKerjaOptions = [
    'Jakarta', 'Morowali', 'Dimana Saja',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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

  Future<void> _loadData() async {
    try {
      final prefs    = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      if (userJson == null) {
        setState(() => _isLoadingData = false);
        return;
      }

      final userData = jsonDecode(userJson);
      final userId   = userData['id'];

      final result = await PersonalService.getPersonalByUserId(userId);

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];

         _namaController.text = data['name']?.toString().isNotEmpty == true
          ? data['name']
          : userData['name'] ?? '';
        _ktpController.text         = data['ktp'] ?? '';
        _tempatLahirController.text  = data['birth_place'] ?? '';
        _nomorAK1Controller.text    = data['nomor_pencarikerja'] ?? '';
        _jurusanController.text     = data['education_major'] ?? '';
        _asalSekolahController.text  = data['education_instansi'] ?? '';

        final birthDate = data['birth_date']?.toString() ?? '';
        if (birthDate.isNotEmpty) {
          final dateOnly = birthDate.split('T')[0];
          final parts    = dateOnly.split('-');
          if (parts.length == 3) {
            _tanggalLahirController.text = '${parts[2]}/${parts[1]}/${parts[0]}';
          }
        }

        _selectedAgama = _agamaOptions.contains(data['religion'])
            ? data['religion'] : null;
        _selectedJenisKelamin = _jenisKelaminOptions.contains(data['gender'])
            ? data['gender'] : null;
        _selectedStatusPernikahan = _statusPernikahanOptions.contains(data['marital_status'])
            ? data['marital_status'] : null;
        _selectedPendidikan = _pendidikanOptions.contains(data['education_stage'])
            ? data['education_stage'] : null;
        _selectedLokasiKerja = _lokasiKerjaOptions.contains(data['lokasi_kerja_yang_diharapkan'])
            ? data['lokasi_kerja_yang_diharapkan'] : null;

        _personalId = data['id'];

        _isNamaDisabled =
          data['name'] != null &&
          data['name'].toString().trim().isNotEmpty;

        _isKtpDisabled =
          data['ktp'] != null &&
          data['ktp'].toString().trim().isNotEmpty;
      }
    } catch (e) {
      debugPrint('Error load data diri: $e');
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  String _toIsoDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 3) return '${parts[2]}-${parts[1]}-${parts[0]}';
      return date;
    } catch (e) {
      return date;
    }
  }

  Future<void> _simpan() async {
    if (_selectedAgama == null ||
        _selectedJenisKelamin == null ||
        _tempatLahirController.text.trim().isEmpty ||
        _tanggalLahirController.text.trim().isEmpty ||
        _selectedStatusPernikahan == null ||
        _nomorAK1Controller.text.trim().isEmpty ||
        _selectedPendidikan == null ||
        _jurusanController.text.trim().isEmpty ||
        _asalSekolahController.text.trim().isEmpty ||
        _selectedLokasiKerja == null) {
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
      if (userJson == null) throw Exception('Sesi user tidak ditemukan. Silakan login kembali.');

      final userData    = jsonDecode(userJson);
      final int localUserId = userData['id'];
      final email       = FirebaseAuth.instance.currentUser?.email ?? '';

      final payload = {
        'user_id'                       : localUserId,
        'name'                          : _namaController.text.trim(),
        'ktp'                           : _ktpController.text.trim(),
        'status'                        : 'Pelamar',
        'kk'                            : '-',
        'gender'                        : _selectedJenisKelamin ?? '-',
        'religion'                      : _selectedAgama ?? '-',
        'birth_place'                   : _tempatLahirController.text.trim(),
        'birth_date'                    : _toIsoDate(_tanggalLahirController.text),
        'marital_status'                : _selectedStatusPernikahan ?? '-',
        'nomor_pencarikerja'            : _nomorAK1Controller.text.trim(),
        'education_stage'               : _selectedPendidikan ?? '-',
        'education_major'               : _jurusanController.text.trim(),
        'education_instansi'            : _asalSekolahController.text.trim(),
        'lokasi_kerja_yang_diharapkan'  : _selectedLokasiKerja ?? '-',
        'email'                         : email,
        'has_experience'                : 'Tidak',
        'current_salary'                : 0,
        'expected_salary'               : 0,
        'phone'                         : '-',
        'no_wa'                         : '-',
      };

      Map<String, dynamic> result;

      if (_personalId != null) {
        result = await PersonalService.updatePersonal(_personalId!, payload);
      } else {
        result = await PersonalService.createPersonal(payload);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        if (_personalId == null) {
          final personalId = result['data']?['id']?.toString() ?? '';
          if (personalId.isNotEmpty) {
            setState(() => _personalId = int.tryParse(personalId));
            await prefs.setString('personal_id', personalId);

            final updatedUser = jsonDecode(prefs.getString('user_data') ?? '{}');
            updatedUser['personal_id'] = personalId;
            await prefs.setString('user_data', jsonEncode(updatedUser));

            debugPrint('Saved personal_id: $personalId');
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _personalId != null
                  ? 'Data diri berhasil diperbarui'
                  : 'Data diri berhasil disimpan',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        String errorMsg = result['message']?.toString() ?? 'Gagal menyimpan data';
        if (result['errors'] != null) errorMsg = result['errors'].toString();
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: Text(
          _personalId != null ? 'Edit Data Diri' : 'Data Diri',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                      _buildInfoBox(),

                      const SizedBox(height: 20),

                      // Nama
                      _buildLabel('Nama Lengkap :'),
                      const SizedBox(height: 6),
                      _buildConditionalField(
                        _namaController,
                        enabled: !_isNamaDisabled,
                        hint: 'Nama belum diisi',
                      ),
                      const SizedBox(height: 4),
                      if (_personalId != null)
                        Text(
                          'Nama tidak dapat diubah di sini',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      const SizedBox(height: 12),

                      // NIK
                      _buildLabel('Nomor KTP :'),
                      const SizedBox(height: 6),
                      _buildConditionalField(
                        _ktpController,
                        enabled: !_isKtpDisabled,
                        hint: 'NIK belum diisi',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NIK tidak dapat diubah',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 12),

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
                      const SizedBox(height: 6),
                      _buildDateField(_tanggalLahirController),

                      const SizedBox(height: 12),

                      _buildDropdown(
                        label: 'Status Pernikahan :',
                        value: _selectedStatusPernikahan,
                        items: _statusPernikahanOptions,
                        onChanged: (v) => setState(() => _selectedStatusPernikahan = v),
                      ),

                      const SizedBox(height: 12),

                      _buildField('Nomor Pencari Kerja (AK1) :', _nomorAK1Controller),

                      _buildDropdown(
                        label: 'Pendidikan Terakhir :',
                        value: _selectedPendidikan,
                        items: _pendidikanOptions,
                        onChanged: (v) => setState(() => _selectedPendidikan = v),
                      ),

                      const SizedBox(height: 12),

                      _buildField('Jurusan :', _jurusanController),

                      _buildField('Asal Sekolah / Universitas :', _asalSekolahController),

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
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _personalId != null ? 'PERBARUI DATA' : 'SIMPAN',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mohon diperhatikan sebelum mengisi formulir',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Pastikan data yang diinput sudah benar dan dapat dipertanggungjawabkan. '
            'Jika data atau dokumen pendukung belum siap, silakan isi formulir di lain waktu.',
            style: TextStyle(fontSize: 12, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ],
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
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildConditionalField(
    TextEditingController controller, {
    required bool enabled,
    String hint = '-',
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? Colors.white
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: TextStyle(
          fontSize: 13,
          color: enabled
              ? Colors.black
              : Colors.grey.shade600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),

          suffixIcon: !enabled
              ? Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: Colors.grey.shade400,
                )
              : null,
        ),
      ),
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
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: const Text('Pilih', style: TextStyle(fontSize: 13)),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: onChanged,
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, size: 20),
            onPressed: () async {
              DateTime initialDate = DateTime(2000);
              if (controller.text.isNotEmpty) {
                try {
                  final parts = controller.text.split('/');
                  if (parts.length == 3) {
                    initialDate = DateTime(
                      int.parse(parts[2]),
                      int.parse(parts[1]),
                      int.parse(parts[0]),
                    );
                  }
                } catch (_) {}
              }

              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );

              if (picked != null) {
                setState(() {
                  controller.text =
                      "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                });
              }
            },
          ),
        ),
      ),
    );
  }
}
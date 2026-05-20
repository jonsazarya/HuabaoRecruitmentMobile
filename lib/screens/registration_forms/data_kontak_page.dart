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
  final _waController                 = TextEditingController();
  final _phoneController              = TextEditingController();
  final _facebookController           = TextEditingController();
  final _linkedinController           = TextEditingController();
  final _namaKontakDaruratController  = TextEditingController();
  final _noHpDaruratController        = TextEditingController();

  String? _selectedHubungan;
  bool _isLoading     = false;
  bool _isLoadingData = true;
  int? _personalId;

  final List<String> _hubunganOptions = [
    'Orang Tua', 'Suami/Istri', 'Saudara', 'Teman', 'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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

        _waController.text                = data['no_wa'] ?? '';
        _phoneController.text             = data['phone'] ?? '';
        _facebookController.text          = data['facebook'] ?? '';
        _linkedinController.text          = data['linkedin'] ?? '';
        _namaKontakDaruratController.text = data['kontak_darurat_name'] ?? '';
        _noHpDaruratController.text       = data['kontak_darurat_hp'] ?? '';

        _selectedHubungan = _hubunganOptions.contains(data['kontak_darurat_hubungan'])
            ? data['kontak_darurat_hubungan'] : null;

        _personalId = data['id'];
      }
    } catch (e) {
      debugPrint('Error load data kontak: $e');
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _simpan() async {
    if (_waController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _facebookController.text.trim().isEmpty ||
        _linkedinController.text.trim().isEmpty ||
        _namaKontakDaruratController.text.trim().isEmpty ||
        _selectedHubungan == null ||
        _noHpDaruratController.text.trim().isEmpty) {
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

      final userData   = jsonDecode(userJson);
      final personalId = _personalId ??
          int.tryParse(userData['personal_id']?.toString() ?? '0') ?? 0;

      if (personalId == 0) {
        throw Exception('ID Personal tidak ditemukan. Silakan login ulang.');
      }

      final payload = {
        'user_id'                  : userData['id'],
        'no_wa'                    : _waController.text.trim(),
        'phone'                    : _phoneController.text.trim(),
        'facebook'                 : _facebookController.text.trim(),
        'linkedin'                 : _linkedinController.text.trim(),
        'kontak_darurat_name'      : _namaKontakDaruratController.text.trim(),
        'kontak_darurat_hubungan'  : _selectedHubungan,
        'kontak_darurat_hp'        : _noHpDaruratController.text.trim(),
      };

      final result = await PersonalService.updatePersonal(personalId, payload);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data kontak berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception(result['message'] ?? 'Gagal memperbarui data');
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
          'Data Kontak',
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
                      _buildInfoBox(),
                      const SizedBox(height: 20),
                      
                      _buildField('Nomor WhatsApp (WA) :', _waController,
                          keyboardType: TextInputType.phone),
                      _buildField('Nomor HP (Telepon) :', _phoneController,
                          keyboardType: TextInputType.phone),
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

                      _buildField('Nama Kontak Darurat :', _namaKontakDaruratController),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Hubungan :',
                              value: _selectedHubungan,
                              items: _hubunganOptions,
                              onChanged: (v) => setState(() => _selectedHubungan = v),
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
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

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
              hint: const Text('Pilih', style: TextStyle(fontSize: 12, color: Colors.grey)),
              items: items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: const TextStyle(fontSize: 13)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
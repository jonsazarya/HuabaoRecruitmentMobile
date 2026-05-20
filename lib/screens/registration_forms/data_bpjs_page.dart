import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recruitment_mobile/services/personal_service.dart';

class DataBpjsPage extends StatefulWidget {
  const DataBpjsPage({super.key});

  @override
  State<DataBpjsPage> createState() => _DataBpjsPageState();
}

class _DataBpjsPageState extends State<DataBpjsPage> {
  final _nomorBpjsKesehatan       = TextEditingController();
  final _nomorBpjsKetenagakerjaan = TextEditingController();
  final _statusBpjsController     = TextEditingController();
  final _catatanBpjsController    = TextEditingController();

  bool _isLoading     = false;
  bool _isLoadingData = true;
  int? _personalId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nomorBpjsKesehatan.dispose();
    _nomorBpjsKetenagakerjaan.dispose();
    _statusBpjsController.dispose();
    _catatanBpjsController.dispose();
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

        _nomorBpjsKesehatan.text       = data['bpjs_kesehatan'] ?? '';
        _nomorBpjsKetenagakerjaan.text = data['bpjs_ketenagakerjaan'] ?? '';
        _statusBpjsController.text     = data['status_bpjs'] ?? '';
        _catatanBpjsController.text    = data['catatan_bpjs'] ?? '';

        _personalId = data['id'];
      }
    } catch (e) {
      debugPrint('Error load data BPJS: $e');
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _simpan() async {
    if (_nomorBpjsKesehatan.text.trim().isEmpty ||
        _nomorBpjsKetenagakerjaan.text.trim().isEmpty ||
        _statusBpjsController.text.trim().isEmpty ||
        _catatanBpjsController.text.trim().isEmpty) {
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
        'user_id'              : userData['id'],
        'bpjs_kesehatan'       : _nomorBpjsKesehatan.text.trim(),
        'bpjs_ketenagakerjaan' : _nomorBpjsKetenagakerjaan.text.trim(),
        'status_bpjs'          : _statusBpjsController.text.trim(),
        'catatan_bpjs'         : _catatanBpjsController.text.trim(),
      };

      final result = await PersonalService.updatePersonal(personalId, payload);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data BPJS berhasil disimpan'),
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
          'Data BPJS',
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
                      _buildField(
                        'Nomor BPJS Kesehatan :',
                        _nomorBpjsKesehatan,
                        keyboardType: TextInputType.number,
                      ),
                      _buildField(
                        'Nomor BPJS Ketenagakerjaan :',
                        _nomorBpjsKetenagakerjaan,
                        keyboardType: TextInputType.number,
                      ),
                      _buildField(
                        'Status BPJS :',
                        _statusBpjsController,
                        hint: 'Contoh: Aktif / Tidak Aktif',
                      ),
                      _buildField(
                        'Catatan BPJS :',
                        _catatanBpjsController,
                        maxLines: 3,
                        hint: 'Tambahkan catatan jika ada',
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
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
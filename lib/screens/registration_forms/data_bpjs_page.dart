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
  final _nomorBpjsKesehatan = TextEditingController();
  final _nomorBpjsKetenagakerjaan = TextEditingController();
  final _statusBpjsController = TextEditingController();
  final _catatanBpjsController = TextEditingController();

  bool _isLoading = false;

  Future<void> _simpan() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      if (userJson == null) throw Exception("Sesi berakhir");

      final userData = jsonDecode(userJson);
      
      final int personalId = int.tryParse(userData['personal_id']?.toString() ?? '0') ?? 0;

      if (personalId == 0) {
        throw Exception("ID Personal tidak ditemukan. Silakan login ulang.");
      }

      final Map<String, dynamic> payload = {
        "user_id": userData['id'],
        "bpjs_kesehatan": _nomorBpjsKesehatan.text,
        "bpjs_ketenagakerjaan": _nomorBpjsKetenagakerjaan.text,
        "status_bpjs": _statusBpjsController.text,
        "catatan_bpjs": _catatanBpjsController.text,
      };

      final result = await PersonalService.updatePersonal(personalId, payload);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data BPJS Berhasil Disimpan'), backgroundColor: Colors.green),
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
        title: const Text('Data BPJS'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField('Nomor BPJS Kesehatan :', _nomorBpjsKesehatan, 
                    keyboardType: TextInputType.number),
                _buildField('Nomor BPJS Ketenagakerjaan :', _nomorBpjsKetenagakerjaan, 
                    keyboardType: TextInputType.number),
                _buildField('Status BPJS :', _statusBpjsController, 
                    hint: 'Contoh: Aktif / Tidak Aktif'),
                _buildField('Catatan BPJS :', _catatanBpjsController, 
                    maxLines: 3, hint: 'Tambahkan catatan jika ada'),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _simpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
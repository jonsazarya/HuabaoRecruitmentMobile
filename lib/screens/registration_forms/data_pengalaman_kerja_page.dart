import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recruitment_mobile/services/work_experience_service.dart';

class DataPengalamanKerjaPage extends StatefulWidget {
  const DataPengalamanKerjaPage({super.key});

  @override
  State<DataPengalamanKerjaPage> createState() =>
      _DataPengalamanKerjaPageState();
}

class _DataPengalamanKerjaPageState extends State<DataPengalamanKerjaPage> {
  final _namaPerusahaanController = TextEditingController();
  final _posisiController = TextEditingController();
  final _jobDeskController = TextEditingController();
  final _mulaiController = TextEditingController();
  final _selesaiController = TextEditingController();

  bool _punyaPengalaman = true;
  bool _masihBekerja = false;
  bool _isLoading = false;

  Future<void> _simpan() async {
    if (!_punyaPengalaman) {
      Navigator.pop(context);
      return;
    }

    if (_namaPerusahaanController.text.trim().isEmpty ||
        _posisiController.text.trim().isEmpty ||
        _jobDeskController.text.trim().isEmpty ||
        _mulaiController.text.trim().isEmpty ||
        (!_masihBekerja &&
            _selesaiController.text.trim().isEmpty)) {

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
      final userData = jsonDecode(userJson!);
      final int userId = userData['id'];

      final Map<String, dynamic> payload = {
        "user_id": userId,
        "perusahaan": _namaPerusahaanController.text,
        "jabatan": _posisiController.text,
        "job_desk": _jobDeskController.text,
        "start_date": _mulaiController.text,
        "end_date": _masihBekerja ? null : _selesaiController.text,
        "until_now": _masihBekerja ? 1 : 0,
      };

      final result = await WorkExperienceService.createWorkExperience(payload);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengalaman kerja berhasil disimpan'),
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Data Pengalaman Kerja', style: TextStyle(
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
                  const Text(
                    'Apakah Anda memiliki pengalaman kerja?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: _punyaPengalaman,
                        activeColor: const Color.fromRGBO(29, 93, 155, 1),
                        onChanged: (v) => setState(() => _punyaPengalaman = v!),
                      ),
                      const Text('Ya', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 16),
                      Radio<bool>(
                        value: false,
                        groupValue: _punyaPengalaman,
                        activeColor: const Color.fromRGBO(29, 93, 155, 1),
                        onChanged: (v) => setState(() => _punyaPengalaman = v!),
                      ),
                      const Text('Tidak', style: TextStyle(fontSize: 13)),
                    ],
                  ),

                  if (_punyaPengalaman) ...[
                    const SizedBox(height: 8),
                    _buildField('Nama Perusahaan :', _namaPerusahaanController),
                    _buildField('Posisi / Jabatan :', _posisiController),
                    _buildField('Job Desk :', _jobDeskController, maxLines: 3),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField('Mulai :', _mulaiController),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateField(
                            'Selesai :',
                            _selesaiController,
                            disabled: _masihBekerja,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _masihBekerja,
                            activeColor: const Color.fromRGBO(29, 93, 155, 1),
                            onChanged: (v) =>
                                setState(() => _masihBekerja = v!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Masih bekerja',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
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
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
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
            maxLines: maxLines,
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
                  () => controller.text = picked.toString().split(' ')[0],
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
}

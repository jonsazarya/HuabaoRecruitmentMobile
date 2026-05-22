import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recruitment_mobile/services/personal_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nikController       = TextEditingController();
  final _teleponController   = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedinController  = TextEditingController();
  final _facebookController  = TextEditingController();

  String? _selectedJenisKelamin;
  String? _selectedPendidikan;

  bool _isLoading     = false;
  bool _isLoadingData = true;
  int? _personalId;

  final List<String> _jenisKelaminOptions = ['Laki-laki', 'Perempuan'];

  final List<String> _pendidikanOptions = [
    'SD/Paket A/MI',
    'SMP/Paket B/Mts',
    'SMA/SMK/Paket C/MA',
    'D1', 'D2', 'D3', 'D4',
    'S1', 'S2', 'S3',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nikController.dispose();
    _teleponController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _facebookController.dispose();
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

        _nikController.text       = data['ktp'] ?? '';
        _teleponController.text   = data['phone'] ?? data['no_wa'] ?? '';
        _instagramController.text = data['instagram'] ?? '';
        _linkedinController.text  = data['linkedin'] ?? '';
        _facebookController.text  = data['facebook'] ?? '';

        _selectedJenisKelamin = _jenisKelaminOptions.contains(data['gender'])
            ? data['gender'] : null;
        _selectedPendidikan = _pendidikanOptions.contains(data['education_stage'])
            ? data['education_stage'] : null;

        _personalId = data['id'];
      }
    } catch (e) {
      debugPrint('Error load edit profile: $e');
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _simpan() async {
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
        'user_id'         : userData['id'],
        'phone'           : _teleponController.text.trim(),
        'no_wa'           : _teleponController.text.trim(),
        'gender'          : _selectedJenisKelamin ?? '',
        'education_stage' : _selectedPendidikan ?? '',
        'instagram'       : _instagramController.text.trim(),
        'linkedin'        : _linkedinController.text.trim(),
        'facebook'        : _facebookController.text.trim(),
      };

      final result = await PersonalService.updatePersonal(personalId, payload);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception(result['message'] ?? 'Gagal memperbarui profil');
      }
    } catch (e) {
      if (!mounted) return;
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
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                      // NIK
                      _buildLabel('NIK :'),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _nikController,
                          enabled: false,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            suffixIcon: Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NIK tidak dapat diubah',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 12),

                      _buildField('No. Telepon / WhatsApp :', _teleponController,
                          keyboardType: TextInputType.phone),

                      // Dropdown Jenis Kelamin
                      _buildLabel('Jenis Kelamin :'),
                      const SizedBox(height: 4),
                      _buildDropdown(
                        value: _selectedJenisKelamin,
                        hint: 'Pilih Jenis Kelamin',
                        items: _jenisKelaminOptions,
                        onChanged: (v) => setState(() => _selectedJenisKelamin = v),
                      ),
                      const SizedBox(height: 12),

                      // Dropdown Pendidikan
                      _buildLabel('Pendidikan Terakhir :'),
                      const SizedBox(height: 4),
                      _buildDropdown(
                        value: _selectedPendidikan,
                        hint: 'Pilih Pendidikan',
                        items: _pendidikanOptions,
                        onChanged: (v) => setState(() => _selectedPendidikan = v),
                      ),
                      const SizedBox(height: 12),

                      // Sosial Media
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Sosial Media',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(29, 93, 155, 1),
                          ),
                        ),
                      ),

                      _buildField('Instagram :', _instagramController),
                      _buildField('LinkedIn :', _linkedinController),
                      _buildField('Facebook :', _facebookController),

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
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'SIMPAN PERUBAHAN',
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

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
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
            obscureText: obscure,
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
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
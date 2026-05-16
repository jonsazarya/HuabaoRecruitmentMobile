import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recruitment_mobile/services/address_service.dart';

class DataAlamatPage extends StatefulWidget {
  const DataAlamatPage({super.key});

  @override
  State<DataAlamatPage> createState() => _DataAlamatPageState();
}

class _DataAlamatPageState extends State<DataAlamatPage> {
  bool _isLoading = false;

  // List Data Dropdown
  List<dynamic> _listProv = [],
      _listKabKtp = [],
      _listKecKtp = [],
      _listDesaKtp = [];
  List<dynamic> _listKabDom = [], _listKecDom = [], _listDesaDom = [];

  // Form KTP
  final _rtRwKtp = TextEditingController();
  final _kodePosKtp = TextEditingController();
  final _alamatKtp = TextEditingController();
  dynamic _selProvKtp, _selKabKtp, _selKecKtp, _selDesaKtp;

  // Form Domisili
  final _rtRwDom = TextEditingController();
  final _kodePosDom = TextEditingController();
  final _alamatDom = TextEditingController();
  dynamic _selProvDom, _selKabDom, _selKecDom, _selDesaDom;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      _listProv = await AddressService.getProvinsi();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _simpan() async {
    if (_selProvKtp == null ||
        _selKabKtp == null ||
        _selKecKtp == null ||
        _selDesaKtp == null ||
        _rtRwKtp.text.trim().isEmpty ||
        _kodePosKtp.text.trim().isEmpty ||
        _alamatKtp.text.trim().isEmpty ||

        _selProvDom == null ||
        _selKabDom == null ||
        _selKecDom == null ||
        _selDesaDom == null ||
        _rtRwDom.text.trim().isEmpty ||
        _kodePosDom.text.trim().isEmpty ||
        _alamatDom.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field alamat wajib diisi'),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');

      if (userJson == null) {
        throw Exception("User tidak ditemukan. Silakan login kembali.");
      }

      final userData = jsonDecode(userJson);

      final payload = {
        "user_id": userData['id'],
        "kategori_wilayah": "01",
        "waktu_terbit_ktp": DateTime.now().toIso8601String(),
        "waktu_terbit_kk": DateTime.now().toIso8601String(),

        "provinsi": _selProvKtp?['id'],
        "kabupaten": _selKabKtp?['id'],
        "kecamatan": _selKecKtp?['id'],
        "desa": _selDesaKtp?['id'],
        "rt_rw": _rtRwKtp.text,
        "kode_pos": _kodePosKtp.text,
        "alamat_ktp": _alamatKtp.text,

        "provinsi_domisili": _selProvDom?['id'],
        "kabupaten_domisili": _selKabDom?['id'],
        "kecamatan_domisili": _selKecDom?['id'],
        "desa_domisili": _selDesaDom?['id'],
        "rt_rw_domisili": _rtRwDom.text,
        "kode_pos_domisili": _kodePosDom.text,
        "alamat_ktp_domisili": _alamatDom.text,

        "is_reference": 0,
      };

      final result = await AddressService.saveAddress(payload);

      if (!mounted) return;

      setState(() => _isLoading = false);

      // ===== CEK RESPONSE =====
      if (result['success'] == true) {

        // Optional simpan address_id
        final addressId = result['data']?['id']?.toString() ?? '';

        if (addressId.isNotEmpty) {
          await prefs.setString('address_id', addressId);

          final userDataString = prefs.getString('user_data') ?? '{}';
          final updatedUserData = jsonDecode(userDataString);

          updatedUserData['address_id'] = addressId;

          await prefs.setString(
            'user_data',
            jsonEncode(updatedUserData),
          );

          debugPrint('Saved address_id: $addressId');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data alamat berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);

      } else {

        String errorMsg =
            result['message']?.toString() ??
            'Gagal menyimpan data alamat';

        if (result['errors'] != null) {
          errorMsg = result['errors'].toString();
        }

        throw Exception(errorMsg);
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
          'Data Alamat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading && _listProv.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Alamat KTP'),
                  const SizedBox(height: 12),

                  _buildRowDropdown(
                    'Provinsi',
                    _selProvKtp,
                    _listProv,
                    (v) async {
                      setState(() {
                        _selProvKtp = v;
                        _selKabKtp = null;
                        _listKabKtp = [];
                      });
                      if (v != null)
                        _listKabKtp = await AddressService.getKabupaten(
                          v['id'],
                        );
                      setState(() {});
                    },
                    'Kabupaten / Kota',
                    _selKabKtp,
                    _listKabKtp,
                    (v) async {
                      setState(() {
                        _selKabKtp = v;
                        _selKecKtp = null;
                        _listKecKtp = [];
                      });
                      if (v != null)
                        _listKecKtp = await AddressService.getKecamatan(
                          v['id'],
                        );
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 10),

                  _buildRowDropdown(
                    'Kecamatan',
                    _selKecKtp,
                    _listKecKtp,
                    (v) async {
                      setState(() {
                        _selKecKtp = v;
                        _selDesaKtp = null;
                        _listDesaKtp = [];
                      });
                      if (v != null)
                        _listDesaKtp = await AddressService.getDesa(v['id']);
                      setState(() {});
                    },
                    'Desa / Kelurahan',
                    _selDesaKtp,
                    _listDesaKtp,
                    (v) => setState(() => _selDesaKtp = v),
                  ),

                  const SizedBox(height: 10),
                  _buildRtRwKodePos(_rtRwKtp, _kodePosKtp),
                  _buildLongTextField('Alamat (KTP) :', _alamatKtp),

                  const SizedBox(height: 25),
                  _sectionTitle('Alamat Saat Ini (Domisili)'),
                  const SizedBox(height: 12),

                  _buildRowDropdown(
                    'Provinsi',
                    _selProvDom,
                    _listProv,
                    (v) async {
                      setState(() {
                        _selProvDom = v;
                        _selKabDom = null;
                        _listKabDom = [];
                      });
                      if (v != null)
                        _listKabDom = await AddressService.getKabupaten(
                          v['id'],
                        );
                      setState(() {});
                    },
                    'Kabupaten / Kota',
                    _selKabDom,
                    _listKabDom,
                    (v) async {
                      setState(() {
                        _selKabDom = v;
                        _selKecDom = null;
                        _listKecDom = [];
                      });
                      if (v != null)
                        _listKecDom = await AddressService.getKecamatan(
                          v['id'],
                        );
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 10),

                  _buildRowDropdown(
                    'Kecamatan',
                    _selKecDom,
                    _listKecDom,
                    (v) async {
                      setState(() {
                        _selKecDom = v;
                        _selDesaDom = null;
                        _listDesaDom = [];
                      });
                      if (v != null)
                        _listDesaDom = await AddressService.getDesa(v['id']);
                      setState(() {});
                    },
                    'Desa / Kelurahan',
                    _selDesaDom,
                    _listDesaDom,
                    (v) => setState(() => _selDesaDom = v),
                  ),

                  const SizedBox(height: 10),
                  _buildRtRwKodePos(_rtRwDom, _kodePosDom),
                  _buildLongTextField('Alamat :', _alamatDom),

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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(29, 93, 155, 1),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildRowDropdown(
    String L1,
    dynamic V1,
    List<dynamic> I1,
    Function(dynamic) C1,
    String L2,
    dynamic V2,
    List<dynamic> I2,
    Function(dynamic) C2,
  ) {
    return Row(
      children: [
        Expanded(child: _buildColumnDropdown(L1, V1, I1, C1)),
        const SizedBox(width: 12),
        Expanded(child: _buildColumnDropdown(L2, V2, I2, C2)),
      ],
    );
  }

  Widget _buildColumnDropdown(
    String label,
    dynamic value,
    List<dynamic> items,
    Function(dynamic) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              isExpanded: true,
              value: value,
              hint: Text(
                "Pilih $label",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item['name'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRtRwKodePos(
    TextEditingController rtRw,
    TextEditingController zip,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildField('RT/RW', rtRw),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildField(
            'Kode Pos',
            zip,
            keyboardType: TextInputType.number,
          ),
        ),
      ],
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
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildLongTextField(String label, TextEditingController controller) {
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
            maxLines: 2,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

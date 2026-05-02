import 'package:flutter/material.dart';

class DataPeminatanPage extends StatefulWidget {
  const DataPeminatanPage({super.key});

  @override
  State<DataPeminatanPage> createState() => _DataPeminatanPageState();
}

class _DataPeminatanPageState extends State<DataPeminatanPage> {
  final _gajiSaatIniController = TextEditingController();
  final _ekspektasiGajiController = TextEditingController();

  String? _selectedKategori;
  String? _selectedKategoriLainnya;
  String? _selectedPosisi;
  String? _selectedPosisiLainnya;

  final List<String> _kategoriOptions = [
    'Produksi', 'Administrasi', 'Teknik', 'Keuangan', 'HRD', 'Lainnya'
  ];
  final List<String> _kategoriLainnyaOptions = [
    'Marketing', 'IT', 'Legal', 'Logistik', 'Lainnya'
  ];
  final List<String> _posisiOptions = [
    'Staff', 'Supervisor', 'Manager', 'Operator', 'Teknisi', 'Lainnya'
  ];
  final List<String> _posisiLainnyaOptions = [
    'Analis', 'Koordinator', 'Kepala Bagian', 'Lainnya'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Data Peminatan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
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
            const SizedBox(height: 12),

            _buildDropdown(
              label: 'Kategori Lainnya :',
              value: _selectedKategoriLainnya,
              items: _kategoriLainnyaOptions,
              onChanged: (v) =>
                  setState(() => _selectedKategoriLainnya = v),
            ),
            const SizedBox(height: 12),

            _buildDropdown(
              label: 'Posisi Yang Dilamar :',
              value: _selectedPosisi,
              items: _posisiOptions,
              onChanged: (v) => setState(() => _selectedPosisi = v),
            ),
            const SizedBox(height: 12),

            _buildDropdown(
              label: 'Posisi Yang Dilamar Lainnya :',
              value: _selectedPosisiLainnya,
              items: _posisiLainnyaOptions,
              onChanged: (v) =>
                  setState(() => _selectedPosisiLainnya = v),
            ),
            const SizedBox(height: 12),

            _buildField('Gaji Saat Ini :', _gajiSaatIniController,
                keyboardType: TextInputType.number),
            _buildField('Ekspektasi Gaji :', _ekspektasiGajiController,
                keyboardType: TextInputType.number),

            const SizedBox(height: 12),

            // Tombol Simpan
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {},
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
                      fontSize: 14, fontWeight: FontWeight.bold),
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
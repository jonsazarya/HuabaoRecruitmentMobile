import 'package:flutter/material.dart';

class DataKursusPage extends StatefulWidget {
  const DataKursusPage({super.key});

  @override
  State<DataKursusPage> createState() => _DataKursusPageState();
}

class _DataKursusPageState extends State<DataKursusPage> {
  final _judulController = TextEditingController();
  final _penyelenggaraController = TextEditingController();
  final _durasiController = TextEditingController();
  final _tahunController = TextEditingController();

  String? _selectedKategori;

  final List<String> _kategoriOptions = [
    'Kursus', 'Pelatihan', 'Sertifikasi', 'Workshop', 'Seminar', 'Lainnya'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Data Kursus / Pelatihan / Sertifikasi'),
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

            _buildField('Judul :', _judulController),
            _buildField('Penyelenggara :', _penyelenggaraController),

            // Durasi & Tahun berdampingan
            Row(
              children: [
                Expanded(
                  child: _buildField('Durasi :', _durasiController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField('Tahun :', _tahunController,
                      keyboardType: TextInputType.number),
                ),
              ],
            ),

            const SizedBox(height: 4),
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
                child: const Text('SIMPAN',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
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

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
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
              items: items
                  .map((item) => DropdownMenuItem(
                      value: item, child: Text(item)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
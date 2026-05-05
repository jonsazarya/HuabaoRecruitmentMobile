import 'package:flutter/material.dart';

class DataKeluargaPage extends StatefulWidget {
  const DataKeluargaPage({super.key});

  @override
  State<DataKeluargaPage> createState() => _DataKeluargaPageState();
}

class _DataKeluargaPageState extends State<DataKeluargaPage> {
  final _noKKController = TextEditingController();
  final _namaController = TextEditingController();
  final _noKTPController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();

  String? _selectedHubungan;
  String? _selectedJenisKelamin;
  final String _namaFile = '';

  final List<String> _hubunganOptions = [
    'Ayah', 'Ibu', 'Suami', 'Istri', 'Anak', 'Saudara', 'Lainnya'
  ];
  final List<String> _jenisKelaminOptions = ['Laki-laki', 'Perempuan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Data Keluarga'),
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
            _buildField('Nomor Kartu Keluarga (No.KK) :', _noKKController,
                keyboardType: TextInputType.number),
            _buildField('Nama :', _namaController),

            _buildDropdown(
              label: 'Hubungan :',
              value: _selectedHubungan,
              items: _hubunganOptions,
              onChanged: (v) => setState(() => _selectedHubungan = v),
            ),
            const SizedBox(height: 12),

            _buildDropdown(
              label: 'Jenis Kelamin :',
              value: _selectedJenisKelamin,
              items: _jenisKelaminOptions,
              onChanged: (v) =>
                  setState(() => _selectedJenisKelamin = v),
            ),
            const SizedBox(height: 12),

            _buildField('Nomor KTP :', _noKTPController,
                keyboardType: TextInputType.number),
            _buildField('Tempat Lahir :', _tempatLahirController),

            // Tanggal Lahir
            _buildLabel('Tanggal Lahir :'),
            const SizedBox(height: 4),
            _buildDateField(_tanggalLahirController),
            const SizedBox(height: 24),

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
            const SizedBox(height: 16),

            // Info file upload
            Row(
              children: [
                const Text(
                  'Berikut Data Keluarga : ',
                  style: TextStyle(fontSize: 13),
                ),
                GestureDetector(
                  onTap: () {
                    // nanti sambungkan ke file picker
                  },
                  child: Text(
                    _namaFile.isEmpty ? 'data_keluarga.pdf' : _namaFile,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color.fromRGBO(29, 93, 155, 1),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
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

  Widget _buildDateField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today_outlined,
                color: Colors.grey, size: 20),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color.fromRGBO(29, 93, 155, 1),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                controller.text =
                    '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
              }
            },
          ),
        ),
      ),
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
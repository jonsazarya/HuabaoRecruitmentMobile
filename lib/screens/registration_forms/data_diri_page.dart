import 'package:flutter/material.dart';

class DataDiriPage extends StatefulWidget {
  const DataDiriPage({super.key});

  @override
  State<DataDiriPage> createState() => _DataDiriPageState();
}

class _DataDiriPageState extends State<DataDiriPage> {
  final _namaController = TextEditingController();
  final _ktpController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _nomorAK1Controller = TextEditingController();
  final _jurusanController = TextEditingController();
  final _asalSekolahController = TextEditingController();

  String? _selectedAgama;
  String? _selectedJenisKelamin;
  String? _selectedStatusPernikahan;
  String? _selectedPendidikan;
  String? _selectedLokasiKerja;

  final List<String> _agamaOptions = [
    'Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'
  ];
  final List<String> _jenisKelaminOptions = ['Laki-laki', 'Perempuan'];
  final List<String> _statusPernikahanOptions = [
    'Belum Menikah', 'Menikah', 'Cerai Hidup', 'Cerai Mati'
  ];
  final List<String> _pendidikanOptions = [
    'SD', 'SMP', 'SMA / SMK', 'D1', 'D2', 'D3', 'D4', 'S1', 'S2', 'S3'
  ];
  final List<String> _lokasiKerjaOptions = [
    'Jakarta', 'Morowali', 'Lainnya'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Data Diri'),
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
            _buildField('Nama Lengkap :', _namaController),
            _buildField('Nomor KTP :', _ktpController,
                keyboardType: TextInputType.number),

            _buildDropdown(
              label: 'Agama :',
              value: _selectedAgama,
              hint: '',
              items: _agamaOptions,
              onChanged: (v) => setState(() => _selectedAgama = v),
            ),
            const SizedBox(height: 12),

            _buildDropdown(
              label: 'Jenis Kelamin :',
              value: _selectedJenisKelamin,
              hint: '',
              items: _jenisKelaminOptions,
              onChanged: (v) => setState(() => _selectedJenisKelamin = v),
            ),
            const SizedBox(height: 12),

            _buildField('Tempat Lahir :', _tempatLahirController),

            // Tanggal Lahir dengan date picker
            _buildLabel('Tanggal Lahir :'),
            const SizedBox(height: 4),
            _buildDateField(_tanggalLahirController),
            const SizedBox(height: 12),

            _buildDropdown(
              label: 'Status Pernikahan :',
              value: _selectedStatusPernikahan,
              hint: '',
              items: _statusPernikahanOptions,
              onChanged: (v) =>
                  setState(() => _selectedStatusPernikahan = v),
            ),
            const SizedBox(height: 12),

            _buildField('Nomor Pencari Kerja (AK 1) :', _nomorAK1Controller),

            _buildDropdown(
              label: 'Pendidikan Terakhir :',
              value: _selectedPendidikan,
              hint: '',
              items: _pendidikanOptions,
              onChanged: (v) => setState(() => _selectedPendidikan = v),
            ),
            const SizedBox(height: 12),

            _buildField('Jurusan :', _jurusanController),
            _buildField('Asal Sekolah/Universitas :', _asalSekolahController),

            _buildDropdown(
              label: 'Lokasi Kerja yang Diharapkan :',
              value: _selectedLokasiKerja,
              hint: '',
              items: _lokasiKerjaOptions,
              onChanged: (v) => setState(() => _selectedLokasiKerja = v),
            ),
            const SizedBox(height: 24),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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

  // Date picker field
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
    required String hint,
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
              hint: Text(hint,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.grey)),
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
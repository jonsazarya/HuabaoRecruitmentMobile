import 'package:flutter/material.dart';

class DataAlamatPage extends StatefulWidget {
  const DataAlamatPage({super.key});

  @override
  State<DataAlamatPage> createState() => _DataAlamatPageState();
}

class _DataAlamatPageState extends State<DataAlamatPage> {
  // KTP
  final _rtRwKtpController = TextEditingController();
  final _kodePosKtpController = TextEditingController();
  final _alamatKtpController = TextEditingController();
  String? _provKtp, _kabKtp, _kecKtp, _desaKtp;

  // Domisili
  final _rtRwDomisiliController = TextEditingController();
  final _kodePosDomisiliController = TextEditingController();
  final _alamatDomisiliController = TextEditingController();
  String? _provDomisili, _kabDomisili, _kecDomisili, _desaDomisili;

  final List<String> _provinsiOptions = [
    'DKI Jakarta', 'Jawa Barat', 'Jawa Tengah', 'Jawa Timur',
    'Banten', 'Bali', 'Sumatera Utara', 'Lainnya'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Data Alamat'),
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

            const Text(
              'Alamat KTP',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(29, 93, 155, 1),
              ),
            ),
            const SizedBox(height: 12),

            _buildRowDropdown(
              leftLabel: 'Provinsi',
              leftValue: _provKtp,
              leftHint: 'Pilih Provinsi',
              leftItems: _provinsiOptions,
              leftOnChanged: (v) => setState(() => _provKtp = v),
              rightLabel: 'Kabupaten / Kota',
              rightValue: _kabKtp,
              rightHint: 'Pilih Kabupaten / Kota',
              rightItems: _provinsiOptions,
              rightOnChanged: (v) => setState(() => _kabKtp = v),
            ),
            const SizedBox(height: 10),

            _buildRowDropdown(
              leftLabel: 'Kecamatan',
              leftValue: _kecKtp,
              leftHint: 'Pilih Kecamatan',
              leftItems: _provinsiOptions,
              leftOnChanged: (v) => setState(() => _kecKtp = v),
              rightLabel: 'Desa / Kelurahan',
              rightValue: _desaKtp,
              rightHint: 'Pilih Desa / Kelurahan',
              rightItems: _provinsiOptions,
              rightOnChanged: (v) => setState(() => _desaKtp = v),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                    child: _buildField(
                        'RT/RW', _rtRwKtpController)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildField(
                        'Kode Pos', _kodePosKtpController,
                        keyboardType: TextInputType.number)),
              ],
            ),

            _buildLabel('Alamat (KTP) :'),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _alamatKtpController,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Apakah saat ini data dengan KTP?',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            const Text(
              'Alamat Saat Ini (Domisili)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(29, 93, 155, 1),
              ),
            ),
            const SizedBox(height: 12),

            _buildRowDropdown(
              leftLabel: 'Provinsi',
              leftValue: _provDomisili,
              leftHint: 'Pilih Provinsi',
              leftItems: _provinsiOptions,
              leftOnChanged: (v) =>
                  setState(() => _provDomisili = v),
              rightLabel: 'Kabupaten / Kota',
              rightValue: _kabDomisili,
              rightHint: 'Pilih Kabupaten / Kota',
              rightItems: _provinsiOptions,
              rightOnChanged: (v) =>
                  setState(() => _kabDomisili = v),
            ),
            const SizedBox(height: 10),

            _buildRowDropdown(
              leftLabel: 'Kecamatan',
              leftValue: _kecDomisili,
              leftHint: 'Pilih Kecamatan',
              leftItems: _provinsiOptions,
              leftOnChanged: (v) =>
                  setState(() => _kecDomisili = v),
              rightLabel: 'Desa / Kelurahan',
              rightValue: _desaDomisili,
              rightHint: 'Pilih Desa / Kelurahan',
              rightItems: _provinsiOptions,
              rightOnChanged: (v) =>
                  setState(() => _desaDomisili = v),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                    child: _buildField(
                        'RT/RW', _rtRwDomisiliController)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildField(
                        'Kode Pos', _kodePosDomisiliController,
                        keyboardType: TextInputType.number)),
              ],
            ),

            _buildLabel('Alamat :'),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _alamatDomisiliController,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

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
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRowDropdown({
    required String leftLabel,
    required String? leftValue,
    required String leftHint,
    required List<String> leftItems,
    required ValueChanged<String?> leftOnChanged,
    required String rightLabel,
    required String? rightValue,
    required String rightHint,
    required List<String> rightItems,
    required ValueChanged<String?> rightOnChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(leftLabel),
              const SizedBox(height: 4),
              _buildDropdownWidget(
                  leftValue, leftHint, leftItems, leftOnChanged),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(rightLabel),
              const SizedBox(height: 4),
              _buildDropdownWidget(
                  rightValue, rightHint, rightItems, rightOnChanged),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownWidget(String? value, String hint,
      List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
              style:
                  const TextStyle(fontSize: 11, color: Colors.grey)),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.grey, size: 18),
          style:
              const TextStyle(fontSize: 12, color: Colors.black87),
          items: items
              .map((item) =>
                  DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
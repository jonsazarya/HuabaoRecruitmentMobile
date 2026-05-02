import 'package:flutter/material.dart';

class DataKontakPage extends StatefulWidget {
  const DataKontakPage({super.key});

  @override
  State<DataKontakPage> createState() => _DataKontakPageState();
}

class _DataKontakPageState extends State<DataKontakPage> {
  final _hpController = TextEditingController();
  final _facebookController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _namaKontakDaruratController = TextEditingController();
  final _noHpDaruratController = TextEditingController();

  String? _selectedHubungan;

  final List<String> _hubunganOptions = [
    'Orang Tua', 'Suami/Istri', 'Saudara', 'Teman', 'Lainnya'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Data Kontak'),
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
            _buildField('Nomor HP/WA :', _hpController,
                keyboardType: TextInputType.phone),
            _buildField('Facebook :', _facebookController),
            _buildField('LinkedIn :', _linkedinController),

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

            // Kontak Darurat
            const Text(
              'Kontak Darurat',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(29, 93, 155, 1),
              ),
            ),
            const SizedBox(height: 12),

            _buildField('Nama :', _namaKontakDaruratController),

            // Hubungan & No HP berdampingan
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Hubungan'),
                      const SizedBox(height: 4),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedHubungan,
                            hint: const Text('Pilih Hubungan',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.grey, size: 18),
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87),
                            items: _hubunganOptions
                                .map((item) => DropdownMenuItem(
                                    value: item, child: Text(item)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedHubungan = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('No.HP/WA'),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _noHpDaruratController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
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
}
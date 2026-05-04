import 'package:flutter/material.dart';

class DataPengalamanKerjaPage extends StatefulWidget {
  const DataPengalamanKerjaPage({super.key});

  @override
  State<DataPengalamanKerjaPage> createState() =>
      _DataPengalamanKerjaPageState();
}

class _DataPengalamanKerjaPageState
    extends State<DataPengalamanKerjaPage> {
  final _namaPerusahaanController = TextEditingController();
  final _posisiController = TextEditingController();
  final _jobDeskController = TextEditingController();
  final _mulaiController = TextEditingController();
  final _selesaiController = TextEditingController();

  bool _punyaPengalaman = true;
  bool _masihBekerja = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Data Pengalaman Kerja'),
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
            // Radio Ya/Tidak
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
                  onChanged: (v) =>
                      setState(() => _punyaPengalaman = v!),
                ),
                const Text('Ya', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 16),
                Radio<bool>(
                  value: false,
                  groupValue: _punyaPengalaman,
                  activeColor: const Color.fromRGBO(29, 93, 155, 1),
                  onChanged: (v) =>
                      setState(() => _punyaPengalaman = v!),
                ),
                const Text('Tidak', style: TextStyle(fontSize: 13)),
              ],
            ),

            if (_punyaPengalaman) ...[
              const SizedBox(height: 8),
              _buildField('Nama Perusahaan :', _namaPerusahaanController),
              _buildField('Posisi / Jabatan :', _posisiController),

              // Job Desk - multiline
              _buildLabel('Job Desk :'),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _jobDeskController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Mulai & Selesai
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Mulai :'),
                        const SizedBox(height: 4),
                        _buildDateField(_mulaiController),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Selesai :'),
                        const SizedBox(height: 4),
                        _buildDateField(_selesaiController,
                            disabled: _masihBekerja),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Checkbox masih bekerja
              Row(
                children: [
                  Checkbox(
                    value: _masihBekerja,
                    activeColor: const Color.fromRGBO(29, 93, 155, 1),
                    onChanged: (v) =>
                        setState(() => _masihBekerja = v!),
                  ),
                  const Text('Masih bekerja',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],

            const SizedBox(height: 16),
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

  Widget _buildDateField(TextEditingController controller,
      {bool disabled = false}) {
    return Container(
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
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today_outlined,
                color: Colors.grey, size: 18),
            onPressed: disabled
                ? null
                : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2020),
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
                      controller.text =
                          '${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                    }
                  },
          ),
        ),
      ),
    );
  }
}
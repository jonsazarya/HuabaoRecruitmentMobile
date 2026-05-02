import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class RegistrationGuidePage extends StatefulWidget {
  const RegistrationGuidePage({super.key});

  @override
  State<RegistrationGuidePage> createState() => _RegistrationGuidePageState();
}

class _RegistrationGuidePageState extends State<RegistrationGuidePage> {
  String? _pdfPath;
  bool _isLoading = true;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final byteData = await rootBundle.load('assets/pdf/panduan_registrasi_recruitment.pdf');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/panduan_registrasi_recruitment.pdf');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      setState(() {
        _pdfPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 93, 155, 1),
        foregroundColor: Colors.white,
        title: const Text('Panduan Registrasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'panduan_registrasi_recruitment.pdf',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
                Icon(Icons.visibility_outlined, color: Colors.grey.shade600, size: 20),
              ],
            ),
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color.fromRGBO(29, 93, 155, 1),
                        ),
                      )
                    : _pdfPath == null
                        ?
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.picture_as_pdf,
                                    size: 60, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                const Text(
                                  'File PDF tidak ditemukan',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Letakkan file di assets/pdf/',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : PDFView(
                            filePath: _pdfPath!,
                            enableSwipe: true,
                            swipeHorizontal: false,
                            autoSpacing: true,
                            pageFling: true,
                            onRender: (pages) {
                              setState(() => _totalPages = pages ?? 0);
                            },
                            onPageChanged: (page, total) {
                              setState(() => _currentPage = page ?? 0);
                            },
                            onError: (error) {
                              debugPrint('PDF Error: $error');
                            },
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
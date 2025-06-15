import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart'; // Nueva librería

class PDFViewerScreen extends StatefulWidget {
  final File file;

  const PDFViewerScreen({super.key, required this.file});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String extractedText = 'Extrayendo texto...';

  @override
  void initState() {
    super.initState();
    _extractTextFromPDF();
  }

  Future<void> _extractTextFromPDF() async {
    try {
      final bytes = await widget.file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      final textExtractor = PdfTextExtractor(document);
      StringBuffer buffer = StringBuffer();

      for (int i = 0; i < document.pages.count; i++) {
        final pageText = textExtractor.extractText(startPageIndex: i, endPageIndex: i);
        buffer.writeln('Página ${i + 1}:\n$pageText\n');
      }

      setState(() {
        extractedText = buffer.toString().trim().isEmpty
            ? 'No se pudo extraer texto.'
            : buffer.toString();
      });

      document.dispose();
    } catch (e) {
      setState(() {
        extractedText = 'Error al extraer texto: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Vista del PDF"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Visualización"),
              Tab(text: "Texto extraído"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PDFView(filePath: widget.file.path),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Text(extractedText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

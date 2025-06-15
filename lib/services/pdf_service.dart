import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/clase.dart';

class PDFService {
  // Metodo para seleccionar un archivo PDF
  static Future<File?> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  // Metodo para extraer texto del PDF
  static Future<String> extractTextFromPDF(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final textExtractor = PdfTextExtractor(document);

      StringBuffer buffer = StringBuffer();
      for (int i = 0; i < document.pages.count; i++) {
        final pageText = textExtractor.extractText(
          startPageIndex: i,
          endPageIndex: i,
        );
        buffer.writeln(pageText);
      }

      document.dispose();
      return buffer.toString().trim();
    } catch (e) {
      //print("Error al extraer texto: $e");
      return '';
    }
  }

  // Funcion para procesar texto y obtener clases
  static List<Clase> extractClasesFromText(String text) {
    final lineas =
        text
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();
    final regexHorario = RegExp(r'\b\d{1,2}:\d{2}-\d{1,2}:\d{2}\b');
    final regexUbicacion = RegExp(r'[A-Za-zÁÉÍÓÚÑáéíóúñ\s]+?\s\d+$');

    String horario = '';
    List<Clase> clases = [];

    for (var linea in lineas) {
      if (clases.length < 5) {
        if (regexHorario.hasMatch(linea)) {
          horario = linea;
          continue;
        }

        if (regexUbicacion.hasMatch(linea)) {
          continue;
        }

        if (horario.isNotEmpty) {
          clases.add(Clase(materia: linea, horario: horario));
        }
      }
    }
    return clases;
  }
}

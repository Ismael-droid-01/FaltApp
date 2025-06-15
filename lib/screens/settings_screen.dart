import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pdf_service.dart';
import '../models/clase.dart';
import '../services/clase_storage_service.dart';
import '../providers/clase_provider.dart';
import 'dart:io';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: Icon(Icons.upload_file),
                title: Text('Cargar archivo de horario'),
                subtitle: Text('Sube un archivo PDF con tu horario de clases'),
                onTap: () => _procesarPDF(context),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.delete_forever),
                title: Text('Restablecer datos'),
                subtitle: Text(
                  'Elimina todas las materias y faltas registradas',
                ),
                onTap: () {
                  _confirmarReset(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _procesarPDF(BuildContext context) async {
    final File? pdf = await PDFService.pickPDF();
    if (pdf != null && context.mounted) {
      final String texto = await PDFService.extractTextFromPDF(pdf);
      final List<Clase> clases = PDFService.extractClasesFromText(texto);
      await ClaseStorageService.agregarMultiplesClases(clases);

      if (!context.mounted) return;
      context.read<ClaseProvider>().cargarClases();

      // Redire la pantalla home
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
        arguments:
            'Horario cargado correctamente, ${clases.length} clases añadidas',
      );
    }
  }

  void _confirmarReset(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar todos los datos? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  // Eliminar clases y faltas
                  await ClaseStorageService.limpiarClases();

                  if (!context.mounted) return;
                  context.read<ClaseProvider>().cargarClases();

                  if (context.mounted) {
                    context
                        .read<ClaseProvider>()
                        .cargarClases(); // Recarga faltas
                    Navigator.pop(context); // Cierra el dialogo

                    // Redire la pantalla home
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                      arguments: 'Datos restablecidos',
                    );
                  }
                },
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

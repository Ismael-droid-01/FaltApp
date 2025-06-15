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
                leading: Icon(Icons.remove_circle_outline),
                title: Text('Eliminar solo faltas'),
                subtitle: Text('Selecciona materias y borra sus faltas'),
                onTap: () => _mostrarSeleccionMaterias(context),
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

  void _mostrarSeleccionMaterias(BuildContext context) {
    final seleccionadas = <String>{};

    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ClaseProvider>(
          builder: (context, claseProvider, _) {
            final clases = claseProvider.clases;

            if (clases.isEmpty) {
              return AlertDialog(
                title: const Text('Sin Clases'),
                content: const Text('No hay clases registradas.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            }

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Selecciona materias'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children:
                          clases.map((clase) {
                            return CheckboxListTile(
                              title: Text(clase.materia),
                              value: seleccionadas.contains(clase.materia),
                              onChanged: (bool? seleccionado) {
                                setState(() {
                                  if (seleccionado == true) {
                                    seleccionadas.add(clase.materia);
                                  } else {
                                    seleccionadas.remove(clase.materia);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        for (final materia in seleccionadas) {
                          await ClaseStorageService.eliminarFaltasDeClase(
                            materia,
                          );
                        }

                        if (!context.mounted) return;
                        context.read<ClaseProvider>().cargarClases();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/',
                          (route) => false,
                          arguments:
                              'Faltas eliminadas de ${seleccionadas.length} materia(s)',
                        );
                      },
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
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

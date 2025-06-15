import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../providers/falta_provider.dart';
import 'package:provider/provider.dart';

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
                // onTap: () {}
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
                  await StorageService.limpiarFaltas();

                  if (context.mounted) {
                    context
                        .read<FaltaProvider>()
                        .cargarFaltas(); // Recarga faltas
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

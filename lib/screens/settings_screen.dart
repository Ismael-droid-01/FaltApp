import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListView(
            shrinkWrap: true,
            children: const [
              ListTile(
                leading: Icon(Icons.upload_file),
                title: Text('Cargar archivo de horario'),
                subtitle: Text('Sube un archivo PDF con tu horario de clases'),
                // onTap: () {}
              ),
              Divider(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}
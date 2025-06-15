import 'package:hive/hive.dart';
import '../models/clase.dart';

class ClaseStorageService {
  static final _box = Hive.box<Clase>('clases');

  static Future<void> agregarClase(Clase clase) async {
    await _box.add(clase);
  }

  static List<Clase> obtenerClases() {
    return _box.values.toList();
  }

  static Future<void> eliminarClase(int index) async {
    await _box.deleteAt(index);
  }

  static Future<void> limpiarClases() async {
    await _box.clear();
  }

  static Future<void> agregarMultiplesClases(List<Clase> clases) async {
    for (var clase in clases) {
      await _box.add(clase);
    }
  }

  static Future<void> agregarFaltaAClase(String materia, DateTime fecha) async {
    // Buscar la clase con la materia dada
    final clase = _box.values.firstWhere(
      (c) => c.materia == materia,
      orElse: () => throw Exception('Clase no encontrada: $materia'),
    );

    // Agregar la nueva falta
    clase.faltas.add(fecha);

    // Guardar los cambios
    await clase.save();
  }
}

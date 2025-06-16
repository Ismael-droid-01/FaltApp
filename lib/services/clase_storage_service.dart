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

  static int obtenerFaltas(String materia) {
    // Buscar la clase con la materia dada
    final clase = _box.values.firstWhere(
      (c) => c.materia == materia, // devuelve null si no existe
    );

    // Retorna la cantidad de faltas de esa clase
    return clase.faltas.length;
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

    // Verificar si ya existe una falta en esa misma fecha (ignorando la hora)
    final yaExiste = clase.faltas.any(
      (f) =>
          f.year == fecha.year && f.month == fecha.month && f.day == fecha.day,
    );

    if (yaExiste) {
      throw Exception('La falta para $materia ya fue registrada en esa fecha.');
    }

    // Agregar la nueva falta
    clase.faltas.add(fecha);

    // Guardar los cambios
    await clase.save();
  }

  static Future<void> eliminarFaltasDeClase(String materia) async {
    final clase = _box.values.firstWhere(
      (c) => c.materia == materia,
      orElse: () => throw Exception('Clase no encontrada: $materia'),
    );

    clase.faltas.clear();
    await clase.save();
  }

  static Future<void> establecerLimiteFaltas(int limite) async {
    final box = await Hive.openBox('ajustes');
    await box.put('limiteFaltas', limite);
  }

  static Future<int> obtenerLimiteFaltas() async {
    final box = await Hive.openBox('ajustes');
    return box.get('limiteFaltas', defaultValue: 3);
  }
}

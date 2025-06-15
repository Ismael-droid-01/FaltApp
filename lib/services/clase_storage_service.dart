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
}

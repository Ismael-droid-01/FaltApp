import 'package:hive/hive.dart';
import '../models/falta.dart';

class StorageService {
  static final _box = Hive.box<Falta>('faltas');

  static Future<void> agregarFalta(Falta falta) async {
    await _box.add(falta);
  }

  static List<Falta> obtenerFaltas() {
    return _box.values.toList();
  }

  static Future<void> eliminarFalta(int index) async {
    await _box.deleteAt(index);
  }

  static Future<void> limpiarFaltas() async {
    await _box.clear();
  }
}

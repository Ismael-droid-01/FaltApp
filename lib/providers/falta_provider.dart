import 'package:flutter/material.dart';
import '../models/falta.dart';
import '../services/falta_storage_service.dart';

class FaltaProvider with ChangeNotifier {
  List<Falta> _faltas = [];

  List<Falta> get faltas => _faltas;

  void cargarFaltas() {
    _faltas = FaltaStorageService.obtenerFaltas();
    notifyListeners();
  }

  Future<void> agregarFalta(Falta falta) async {
    await FaltaStorageService.agregarFalta(falta);
    cargarFaltas();
  }

  Future<void> eliminarFalta(int index) async {
    await FaltaStorageService.eliminarFalta(index);
    cargarFaltas();
  }
}

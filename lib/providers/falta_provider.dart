import 'package:flutter/material.dart';
import '../models/falta.dart';
import '../services/storage_service.dart';

class FaltaProvider with ChangeNotifier {
  List<Falta> _faltas = [];

  List<Falta> get faltas => _faltas;

  void cargarFaltas() {
    _faltas = StorageService.obtenerFaltas();
    notifyListeners();
  }

  Future<void> agregarFalta(Falta falta) async {
    await StorageService.agregarFalta(falta);
    cargarFaltas();
  }

  Future<void> eliminarFalta(int index) async {
    await StorageService.eliminarFalta(index);
    cargarFaltas();
  }
}
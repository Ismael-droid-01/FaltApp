import 'package:flutter/material.dart';
import '../models/clase.dart';
import '../services/clase_storage_service.dart';

class ClaseProvider extends ChangeNotifier {
  List<Clase> _clases = [];

  List<Clase> get clases => _clases;

  void cargarClases() {
    _clases = ClaseStorageService.obtenerClases();
    notifyListeners();
  }

  Future<void> agregarClase(Clase clase) async {
    await ClaseStorageService.agregarClase(clase);
    cargarClases();
  }

  Future<void> eliminarClase(int index) async {
    await ClaseStorageService.eliminarClase(index);
    cargarClases();
  }

  Future<void> limpiarClases() async {
    await ClaseStorageService.limpiarClases();
    cargarClases();
  }

  Future<void> agregarMultiplesClases(List<Clase> clases) async {
    await ClaseStorageService.agregarMultiplesClases(clases);
    cargarClases();
  }
}

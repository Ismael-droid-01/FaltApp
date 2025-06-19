import 'package:flutter/material.dart';
import '../models/clase.dart';

class ClaseUtils {
  static String obtenerMateriaActual(List<Clase> clases) {
    final ahora = TimeOfDay.now();
    //final ahora = TimeOfDay(hour: 10, minute: 05);
    final diaSemana = DateTime.now().weekday;
    //final diaSemana = 1;
    print(ahora);
    print(diaSemana);

    if (diaSemana >= 6) {
      // 6 = sábado, 7 = domingo
      return ''; // No hay clases en fin de semana
    }

    for (final clase in clases) {
      //print("Clase: ${clase.horario}");
      final partes = clase.horario.split('-');
      if (partes.length != 2) continue;

      final inicio = _parseTimeOfDay(partes[0]);
      final fin = _parseTimeOfDay(partes[1]);

      if (_isHoraDentroDelRango(ahora, inicio, fin)) {
        return clase.materia;
      }
    }
    return '';
  }

  static TimeOfDay _parseTimeOfDay(String horaStr) {
    final partes = horaStr.split(':');
    return TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
  }

  static bool _isHoraDentroDelRango(
    TimeOfDay actual,
    TimeOfDay inicio,
    TimeOfDay fin,
  ) {
    final actualMinutes = actual.hour * 60 + actual.minute;
    final inicioMinutes = inicio.hour * 60 + inicio.minute;
    final finMinutes = fin.hour * 60 + fin.minute;

    return actualMinutes >= inicioMinutes && actualMinutes <= finMinutes;
  }
}

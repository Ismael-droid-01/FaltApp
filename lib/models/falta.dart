import 'package:hive/hive.dart';

part 'falta.g.dart';

@HiveType(typeId: 1)
class Falta extends HiveObject {
  @HiveField(0)
  final String materia;

  @HiveField(1)
  final DateTime fecha;

  Falta({required this.materia, required this.fecha});
}

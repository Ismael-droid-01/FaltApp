// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClaseAdapter extends TypeAdapter<Clase> {
  @override
  final int typeId = 0;

  @override
  Clase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Clase(
      materia: fields[0] as String,
      horario: fields[1] as String,
      faltas: (fields[2] as List).cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, Clase obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.materia)
      ..writeByte(1)
      ..write(obj.horario)
      ..writeByte(2)
      ..write(obj.faltas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

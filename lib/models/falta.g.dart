// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'falta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FaltaAdapter extends TypeAdapter<Falta> {
  @override
  final int typeId = 0;

  @override
  Falta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Falta(
      materia: fields[0] as String,
      fecha: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Falta obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.materia)
      ..writeByte(1)
      ..write(obj.fecha);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaltaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

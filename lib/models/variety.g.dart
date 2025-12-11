// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variety.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VarietyAdapter extends TypeAdapter<Variety> {
  @override
  final int typeId = 2;

  @override
  Variety read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Variety(
      id: fields[0] as int,
      varietyCode: fields[1] as int,
      name: fields[2] as String,
      licensor: fields[3] as String,
      varietyColor: fields[4] as String,
      productType: fields[5] as String,
      activate: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Variety obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.varietyCode)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.licensor)
      ..writeByte(4)
      ..write(obj.varietyColor)
      ..writeByte(5)
      ..write(obj.productType)
      ..writeByte(6)
      ..write(obj.activate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VarietyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticking_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StickingRecordAdapter extends TypeAdapter<StickingRecord> {
  @override
  final int typeId = 3;

  @override
  StickingRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StickingRecord(
      variety: fields[0] as String,
      employee: fields[1] as String,
      numberStuck: fields[2] as int,
      durationHours: fields[3] as double,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StickingRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.variety)
      ..writeByte(1)
      ..write(obj.employee)
      ..writeByte(2)
      ..write(obj.numberStuck)
      ..writeByte(3)
      ..write(obj.durationHours)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StickingRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

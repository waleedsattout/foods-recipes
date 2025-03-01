// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeasonInfoAdapter extends TypeAdapter<SeasonInfo> {
  @override
  final int typeId = 4;

  @override
  SeasonInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeasonInfo(
      name: fields[0] as String,
      icon: fields[1] as IconData,
      backgroundColor: fields[2] as Color,
      textColor: fields[3] as Color,
    );
  }

  @override
  void write(BinaryWriter writer, SeasonInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.icon)
      ..writeByte(2)
      ..write(obj.backgroundColor)
      ..writeByte(3)
      ..write(obj.textColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

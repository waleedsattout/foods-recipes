// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'images.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImagesAdapter extends TypeAdapter<Images> {
  @override
  final int typeId = 6;

  @override
  Images read(BinaryReader reader) {
    return Images(imageData: reader.read());
  }

  @override
  void write(BinaryWriter writer, Images obj) {
    writer.write(obj.imageData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImagesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

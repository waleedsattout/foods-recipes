import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';

part 'images.g.dart';

@HiveType(typeId: 6)
class Images extends HiveObject {
  @HiveType(typeId: 0)
  Uint8List? imageData;

  Images({required this.imageData});
}

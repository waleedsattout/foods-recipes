import 'package:hive/hive.dart';

part 'measurement.g.dart';

@HiveType(typeId: 7)
class Measurement extends HiveObject {
  @HiveField(0)
  String name;

  Measurement({required this.name});

  factory Measurement.fromJson(Map<String, dynamic> json) => Measurement(
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() {
    // Accessing fields using getters is recommended by Hive
    return {
      'name': name,
    };
  }
}

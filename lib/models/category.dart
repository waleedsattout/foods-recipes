import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String name;

  Category({required this.name});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() {
    // Accessing fields using getters is recommended by Hive
    return {
      'name': name,
    };
  }
}

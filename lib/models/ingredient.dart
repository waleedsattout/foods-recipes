import 'package:hive/hive.dart';

part 'ingredient.g.dart';

@HiveType(typeId: 2)
class Ingredient extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int categoryId;

  Ingredient({required this.name, required this.categoryId});

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json['name'] as String,
        categoryId: json['categoryId'] as int,
      );

  Map<String, dynamic> toJson() {
    // Accessing fields using getters is recommended by Hive
    return {
      'name': name,
      'categoryId': categoryId,
    };
  }
}

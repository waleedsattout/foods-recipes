import 'package:hive/hive.dart';

part 'recipe_ingredient.g.dart';

@HiveType(typeId: 3)
class RecipeIngredient extends HiveObject {
  @HiveField(0)
  int recipeId;

  @HiveField(1)
  int ingredientId;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  int unitId;

  RecipeIngredient({
    required this.recipeId,
    required this.unitId,
    required this.quantity,
    required this.ingredientId,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeIngredient(
        recipeId: json['recipeId'] as int,
        ingredientId: json['ingredientId'] as int,
        quantity: json['quantity'] as int,
        unitId: json['unitId'] as int,
      );

  Map<String, dynamic> toJson() {
    // Accessing fields using getters is recommended by Hive
    return {
      'recipeId': recipeId,
      'ingredientId': ingredientId,
      'quantity': quantity,
      'unitId': unitId,
    };
  }
}

import 'package:foods/models/category.dart';
import 'package:foods/models/images.dart';
import 'package:foods/models/ingredient.dart';
import 'package:foods/models/measurement.dart';
import 'package:foods/models/recipe.dart';
import 'package:foods/models/recipe_ingredient.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const String recipesBox = 'recipesBox';
  static const String ingredientsBox = 'ingredientsBox';
  static const String categoriesBox = 'categoriesBox';
  static const String recipeIngredientsBox = 'recipeIngredientsBox';
  static const String measurementBox = 'measurementBox';
  static const String images = 'images';
}

Future<void> initHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(MeasurementAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(IngredientAdapter());
  Hive.registerAdapter(RecipeAdapter());
  Hive.registerAdapter(RecipeIngredientAdapter());
  Hive.registerAdapter(ImagesAdapter());

  var meas = await Hive.openBox<Measurement>(HiveBoxes.measurementBox);
  await Hive.openBox<Category>(HiveBoxes.categoriesBox);
  await Hive.openBox<Ingredient>(HiveBoxes.ingredientsBox);
  await Hive.openBox<RecipeIngredient>(HiveBoxes.recipeIngredientsBox);
  await Hive.openBox<Recipe>(HiveBoxes.recipesBox);
  await Hive.openBox<Images>(HiveBoxes.images);

  if (meas.isEmpty) {
    for (var measure in [
      "gram (g)",
      "kilogram (kg)",
      "milliliter (mL)",
      "liter (L)",
      "teaspoon (tsp)",
      "tablespoon ( Tbsp)",
      "cup (c)",
      "teacup (tc)",
      "pinch",
      "clove"
    ]) {
      await meas.add(Measurement(name: measure));
    }
  }
}

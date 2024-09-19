import 'package:foods/constants.dart';
import 'package:foods/models/ingredient.dart';
import 'package:foods/models/category.dart';
import 'package:foods/models/measurement.dart';
import 'package:foods/models/recipe_ingredient.dart';
import 'package:hive/hive.dart';
import 'package:foods/hive/hive_boxes.dart';

class IngredientService {
  final Box<Ingredient> _ingredientBox =
      Hive.box<Ingredient>(HiveBoxes.ingredientsBox);

  final Box<RecipeIngredient> _recipeIngredientsBox =
      Hive.box<RecipeIngredient>(HiveBoxes.recipeIngredientsBox);

  final Box<Measurement> _measurementBox =
      Hive.box<Measurement>(HiveBoxes.measurementBox);

  final Box<Category> _categoriesBox =
      Hive.box<Category>(HiveBoxes.categoriesBox);

  Ingredient getIngredient(int key) {
    return _ingredientBox.values.where((element) => element.key == key).first;
  }

  List<RecipeIngredient> getAllRecipeIngredients(int recipeKey) {
    return _recipeIngredientsBox.values
        .where((e) => e.recipeId == recipeKey)
        .toList();
  }

  Future<void> deleteRecipeIngredient(int key) async {
    await _recipeIngredientsBox.delete(key);
  }

  Future<void> deleteSpecificRecipeIngredient(
      int recipeKey, int ingredientKey) async {
    var data = _recipeIngredientsBox.values.where(
        (e) => e.ingredientId == ingredientKey && e.recipeId == recipeKey);
    if (data.isNotEmpty) {
      var found = data.first;
      await _recipeIngredientsBox.delete(found.key);
    }
  }

  Future<List<Ingredient>> getAllIngredients() async {
    return _ingredientBox.values.toList();
  }

  String getIngredientNameByKey(int ingredientId) {
    return _ingredientBox.values.where((e) => e.key == ingredientId).first.name;
  }

  Future<String> getIngredientQuantityBeRecipe(
      int recipeKey, int ingredientKey) async {
    List<Measurement> measurements = await getAllMeasurements();

    var found = _recipeIngredientsBox.values.where(
        (e) => e.recipeId == recipeKey && e.ingredientId == ingredientKey);

    if (found.isNotEmpty) {
      var measure = measurements.where((e) => e.key == found.first.unitId);
      if (measure.isNotEmpty) {
        return "${found.first.quantity} ${measure.first.name}";
      } else {
        return "Error 001";
      }
    } else {
      return "Error 002";
    }
  }

  Future<List<Ingredient>> getIngredientsWithout(
      {required List<Ingredient> excludeItems}) async {
    return (await getAllIngredients()).where((ingredient) {
      return !excludeItems.contains(ingredient);
    }).toList();
  }

  Future<void> editRecipeIngredients(
      List<RecipeIngredient> recipeIngredient) async {
    Box<RecipeIngredient> recipeIngredientBox =
        await Hive.openBox<RecipeIngredient>(HiveBoxes.recipeIngredientsBox);
    for (var resIng in recipeIngredient) {
      if (resIng.key == null) {
        recipeIngredientBox.add(resIng);
      } else {
        await _recipeIngredientsBox.put(resIng.key, resIng);
      }
    }
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    await _ingredientBox.add(ingredient);
  }

  Future<void> deleteIngredient(int ingredientKey) async {
    await _ingredientBox.delete(ingredientKey);
    recipeService.deleteRecipeByIngredientKey(ingredientKey);
  }

  Future<void> editIngredient(int ingredientKey, Ingredient ingredient) async {
    await _ingredientBox.putAt(ingredientKey, ingredient);
  }

  Future<void> addCategory(Category category) async {
    await _categoriesBox.add(category);
  }

  Future<void> deleteCategory(int categoryKey) async {
    await _categoriesBox.delete(categoryKey);
  }

  Future<void> editCategory(int categoryKey, Category category) async {
    await _categoriesBox.putAt(categoryKey, category);
  }

  Future<List<Category>> getAllCategories() async {
    return _categoriesBox.values.toList();
  }

  String getCategoryNameByKey(int categoryKey) {
    return _categoriesBox.values.where((e) => e.key == categoryKey).first.name;
  }

  Future<List<Category>> searchCategories(String text) async {
    return _categoriesBox.values
        .where((category) => category.name.contains(text))
        .toList();
  }

  Future<Category> getCategoryByKey(int key) async {
    return _categoriesBox.values.where((e) => e.key == key).first;
  }

  Future<List<Measurement>> getAllMeasurements() async {
    return _measurementBox.values.toList();
  }

  Future<void> addMeasurement(Measurement unit) async {
    await _measurementBox.add(unit);
  }

  Future<void> editMeasurement(int key, Measurement unit) async {
    await _measurementBox.put(key, unit);
  }

  Future<void> deleteMeasurement(int key) async {
    await _measurementBox.delete(key);
  }
}

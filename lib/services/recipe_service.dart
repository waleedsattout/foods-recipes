import 'dart:typed_data';
import 'package:foods/constants.dart';
import 'package:foods/models/category.dart';
import 'package:foods/models/ingredient.dart';
import 'package:foods/models/recipe.dart';
import 'package:foods/models/recipe_ingredient.dart';
import 'package:foods/models/season_info.dart';
import 'package:foods/utils/image_saver.dart';
import 'package:foods/utils/notificatoins.dart';
import 'package:hive/hive.dart';
import 'package:foods/hive/hive_boxes.dart';

class RecipeService {
  Box<Recipe> recipesBox = Hive.box<Recipe>(HiveBoxes.recipesBox);

  Future<void> addRecipe(
      Recipe recipe, List<RecipeIngredient> ingredientsQuantity) async {
    try {
      final savedRecipeKey = await recipesBox.add(recipe);

      Box<RecipeIngredient> ingredientRecipeBox =
          Hive.box<RecipeIngredient>(HiveBoxes.recipeIngredientsBox);

      for (RecipeIngredient resIng in ingredientsQuantity) {
        resIng.recipeId = savedRecipeKey;
        await ingredientRecipeBox.add(resIng);
      }
    } catch (e) {
      Notifications().showNotificationAndroid(
        "Error",
        "Something went wrong.",
        styleInformation: [
          "An error occured when trying to add the recipe.",
          "try again or contact the developers."
        ],
      );
    }
  }

  Future<List<Recipe>> getAllRecipes({int? limit}) async {
    if (limit != null) {
      return recipesBox.values.take(limit).toList();
    } else {
      return recipesBox.values.toList();
    }
  }

  Future<List<Recipe>> searchRecipe(String text) async {
    return recipesBox.values.where((recipe) {
      return recipe.name.contains(text);
    }).toList();
  }

  Future<Recipe> getRecipeData(int recipeId) async {
    return recipesBox.values.where((e) => e.key == recipeId).first;
  }

  Future<void> editRecipeData(
      int recipeKey, Recipe recipe, Uint8List? imageData) async {
    String imageName = "";
    if (imageData != null) {
      if (sharedDataProvider.imageName == "") {
        imageName = DateTime.now().millisecondsSinceEpoch.toString();
      } else {
        imageName = sharedDataProvider.imageName;
      }
      recipe.imageName = imageName;
      await ImageSaver().saveImageAsFile(imageData, imageName);
    }
    await recipesBox.put(recipeKey, recipe);
  }

  Future<void> deleteRecipe(int recipeKey) async {
    await recipesBox.delete(recipeKey);
  }

  Future<void> deleteRecipeByIngredientKey(int ingredientKey) async {
    Box<RecipeIngredient> recipeIngredientsBox =
        Hive.box(HiveBoxes.recipeIngredientsBox);
    List<RecipeIngredient> recipeIngredient =
        recipeIngredientsBox.values.toList();

    for (var item in recipeIngredient) {
      if (item.ingredientId == ingredientKey) {
        await recipesBox.delete(item.recipeId);
        recipeIngredientsBox.delete(item.key);
      }
    }
  }

  Future<List<Recipe>> searchRecipes(
      {SeasonInfo? season,
      List<Ingredient>? ingredients,
      double? rating,
      int? limit}) async {
    List<Recipe> allRecipes = await getAllRecipes();
    List<Recipe> filteredRecipes = allRecipes.where((recipe) {
      bool matchesSeason = season == null ||
          season.name == "All year" ||
          recipe.season == season.name;
      List<RecipeIngredient> recipeIngredient =
          ingredientService.getAllRecipeIngredients(recipe.key);
      bool matchesIngredients = ingredients!.isEmpty ||
          ingredientMatches(ingredients, recipeIngredient);
      bool matchesRating = rating == null || rating >= recipe.rating;

      return matchesSeason && matchesIngredients && matchesRating;
    }).toList();
    if (limit != null) {
      return filteredRecipes.take(limit).toList();
    } else {
      return filteredRecipes;
    }
  }

  bool ingredientMatches(
      List<Ingredient> ingredients, List<RecipeIngredient> recipeIngredients) {
    final recipeIngredientMap = recipeIngredients
        .asMap()
        .map((index, resIng) => MapEntry(resIng.ingredientId, resIng));

    return ingredients
        .every((ingredient) => recipeIngredientMap.containsKey(ingredient.key));
  }

  Future<List<Recipe>> searchRecipesByIngredientCategory(
      String categoryName) async {
    final recipesBox = Hive.box<Recipe>(HiveBoxes.recipesBox);
    final ingredientsBox = Hive.box<Ingredient>(HiveBoxes.ingredientsBox);
    final categoriesBox = Hive.box<Category>(HiveBoxes.categoriesBox);
    final recipeIngredientsBox =
        Hive.box<RecipeIngredient>(HiveBoxes.recipeIngredientsBox);

    // Get category by name
    final category =
        categoriesBox.values.firstWhere((cat) => cat.name == categoryName);

    // Get ingredients in the category
    final ingredients = ingredientsBox.values
        .where((ing) => ing.categoryId == category.key)
        .toList();

    // Get recipe-ingredient mappings for these ingredients
    final recipeIngredientMappings = recipeIngredientsBox.values
        .where(
            (ri) => ingredients.map((ing) => ing.key).contains(ri.ingredientId))
        .toList();

    // Collect unique recipe keys
    final recipeKeys =
        recipeIngredientMappings.map((ri) => ri.recipeId).toSet();

    // Get recipes from keys and filter out null values
    final recipes = recipeKeys
        .map((key) => recipesBox.get(key))
        .whereType<Recipe>()
        .toList();

    return recipes;
  }
}

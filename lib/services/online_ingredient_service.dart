import 'package:foods/models/ingredient.dart';
import 'package:foods/models/category.dart';
import 'package:foods/models/measurement.dart';
import 'package:foods/models/recipe_ingredient.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OnlineIngredientService {
  final String baseUrl = "127.0.0.1:8787";
  // final String baseUrl = "foods.waleedsattout.workers.dev";

  Future<Ingredient> getIngredient(int key) async {
    final response = await http.get(Uri.parse('$baseUrl/api/ingredients/$key'));

    if (response.statusCode == 200) {
      return Ingredient.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load ingredient');
    }
  }

  Future<List<RecipeIngredient>> getAllRecipeIngredients(int recipeKey) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/recipes/$recipeKey/ingredients'));

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse
          .map((data) => RecipeIngredient.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load recipe ingredients');
    }
  }

  Future<void> deleteRecipeIngredient(int key) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/api/recipe-ingredients/$key'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete recipe ingredient');
    }
  }

  Future<List<Ingredient>> getAllIngredients() async {
    final response = await http.get(Uri.http(baseUrl, 'api/ingredients'));

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Ingredient.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load ingredients');
    }
  }

  Future<String> getIngredientNameByKey(int ingredientId) async {
    final ingredient = await getIngredient(ingredientId);
    return ingredient.name;
  }

  Future<String> getIngredientQuantityBeRecipe(
      int recipeKey, int ingredientKey) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/api/recipes/$recipeKey/ingredients/$ingredientKey'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return "${data['quantity']} ${data['unit']}";
    } else {
      throw Exception('Failed to load ingredient quantity');
    }
  }

  Future<List<Ingredient>> getIngredientsWithout(
      {required List<Ingredient> excludeItems}) async {
    List<Ingredient> allIngredients = await getAllIngredients();
    return allIngredients
        .where((ingredient) => !excludeItems.contains(ingredient))
        .toList();
  }

  Future<void> editRecipeIngredients(
      List<RecipeIngredient> recipeIngredients) async {
    for (var recipeIngredient in recipeIngredients) {
      final response = await http.put(
        Uri.parse('$baseUrl/api/recipe-ingredients/${recipeIngredient.key}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(recipeIngredient.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to edit recipe ingredient');
      }
    }
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ingredients'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(ingredient.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add ingredient');
    }
  }

  Future<void> deleteIngredient(int ingredientKey) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/api/ingredients/$ingredientKey'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete ingredient');
    }
  }

  Future<void> editIngredient(int ingredientKey, Ingredient ingredient) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/ingredients/$ingredientKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(ingredient.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit ingredient');
    }
  }

  Future<void> addCategory(Category category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(category.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add category');
    }
  }

  Future<void> deleteCategory(int categoryKey) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/api/categories/$categoryKey'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete category');
    }
  }

  Future<void> editCategory(int categoryKey, Category category) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/categories/$categoryKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(category.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit category');
    }
  }

  Future<List<Category>> getAllCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/api/categories'));

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Category.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<String> getCategoryNameByKey(int categoryKey) async {
    final category = await getCategoryByKey(categoryKey);
    return category.name;
  }

  Future<List<Category>> searchCategories(String text) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/categories/search?query=$text'));

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Category.fromJson(data)).toList();
    } else {
      throw Exception('Failed to search categories');
    }
  }

  Future<Category> getCategoryByKey(int key) async {
    final response = await http.get(Uri.parse('$baseUrl/api/categories/$key'));

    if (response.statusCode == 200) {
      return Category.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load category');
    }
  }

  Future<List<Measurement>> getAllMeasurements() async {
    final response = await http.get(Uri.parse('$baseUrl/api/measurements'));

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Measurement.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load measurements');
    }
  }

  Future<void> addMeasurement(Measurement unit) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/measurements'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(unit.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add measurement');
    }
  }

  Future<void> editMeasurement(int key, Measurement unit) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/measurements/$key'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(unit.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit measurement');
    }
  }

  Future<void> deleteMeasurement(int key) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/api/measurements/$key'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete measurement');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:foods/constants.dart';
import 'package:foods/models/ingredient.dart';
import 'package:foods/models/recipe.dart';
import 'package:foods/models/recipe_ingredient.dart';
import 'package:foods/models/season_info.dart';
import 'package:foods/screens/add_recipe_screen.dart';
import 'dart:typed_data';
import 'package:foods/utils/image_saver.dart';
import 'package:foods/utils/notificatoins.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SharedDataProvider with ChangeNotifier {
  final ImageSaver _imageSaver = ImageSaver();
  List<Ingredient> selectedIngredients = [];
  List<Ingredient> ingredients = [];
  Uint8List? imageData;
  String imageName = '';
  String recipeName = '';
  String recipeDescription = '';
  List<RecipeIngredient> recipeIngredients = [];
  List<String> steps = [];
  final SeasonInfo seasonError = SeasonInfo(
      name: 'error',
      icon: Icons.error,
      backgroundColor: colorScheme.errorContainer,
      textColor: colorScheme.error);
  late SeasonInfo season = seasonError;
  SharedDataProvider? _prov;
  double rating = 0;

  SharedDataProvider() {
    ingredientService.getAllIngredients().then((e) {
      ingredients = e;
    });
  }

  void setProv(SharedDataProvider prov) {
    _prov = prov;
  }

  void addStep(String step) {
    steps.add(step);
    notifyListeners();
  }

  void updateStep(int index, String step) {
    steps[index] = step;
    notifyListeners();
  }

  void removeStep(int index) {
    steps.removeAt(index);
    notifyListeners();
  }

  void saveRecipeName(String name) {
    recipeName = name;
    notifyListeners();
  }

  void saveRecipeDescription(String description) {
    recipeDescription = description;
    notifyListeners();
  }

  void selectIngredient(Ingredient ingredient) {
    selectedIngredients.add(ingredient);
    notifyListeners();
  }

  void setImageData(Uint8List newImageData) {
    imageData = newImageData;
    notifyListeners();
  }

  void removeIngredientFromRecipe(Ingredient ingredient) {
    selectedIngredients.remove(ingredient);
    var found = recipeIngredients.where(
      (ing) => ing.ingredientId == ingredient.key,
    );
    if (found.isNotEmpty) {
      recipeIngredients.remove(found.first);
    }
    notifyListeners();
  }

  void addIngredientToRecipe(RecipeIngredient resIng) {
    recipeIngredients.add(resIng);
  }

  Future<void> submitRecipe(BuildContext ctx) async {
    if ((recipeName == "" ||
            recipeDescription == "" ||
            season == seasonError ||
            steps == [] ||
            imageName == "") &&
        ctx.mounted) {
      Notifications().showSnackBar("Something went wrong.", ctx);

      return;
    }
    if (isAndroid) await _imageSaver.saveImage(imageData!, imageName);
    recipeService.addRecipe(
        Recipe(
            name: recipeName,
            description: recipeDescription,
            season: season.name,
            steps: steps,
            imageName: imageName,
            rating: rating),
        recipeIngredients);
    if (ctx.mounted) {
      Navigator.pushReplacement(ctx,
          MaterialPageRoute(builder: (context) => const AddRecipeScreen()));
      var appLocalizations = AppLocalizations.of(ctx);
      Notifications().showSnackBar(
          appLocalizations!.modelActionSuccess(
            appLocalizations.recipe,
            appLocalizations.add,
          ),
          null);
    }
    reset();
  }

  void reset() {
    imageData = null;
    imageName = "";
    recipeName = "";
    recipeDescription = "";
    steps = [];
    recipeIngredients = [];
    selectedIngredients = [];
    season = seasonError;
    if (_prov != null) _prov!.reset();
    _prov = null;
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}

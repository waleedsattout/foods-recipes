import 'package:flutter/material.dart';
import 'package:foods/components/seasons_selector.dart';
import 'package:foods/constants.dart';
import 'package:foods/models/recipe.dart';
import 'package:foods/models/recipe_ingredient.dart';
import 'package:foods/screens/add_recipe_form_screen.dart';
import 'package:foods/screens/ingredients_definition_screen.dart';
import 'package:foods/screens/recipe_steps_screen.dart';
import 'package:foods/utils/image_saver.dart';
import 'package:foods/utils/notificatoins.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final int recipeKey;

  const RecipeDetailsScreen({
    super.key,
    required this.recipeKey,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  Recipe? recipe;
  Image? image;
  List<RecipeIngredient> recipeIngredient = [];
  List<Widget> list = [];

  @override
  void initState() {
    super.initState();
    _getRecipe();
  }

  Future<void> _fetchImage() async {
    final fetchedImage = await ImageSaver()
        .displayImageFromFile(recipe!.imageName, context: context);
    setState(() {
      image = fetchedImage;
    });
  }

  Future<void> _getRecipe() async {
    await recipeService.getAllRecipes();

    final fetchedRecipe = (await recipeService.getAllRecipes()).firstWhere(
      (element) => element.key == widget.recipeKey,
    );

    final fetchedIngredients =
        ingredientService.getAllRecipeIngredients(widget.recipeKey);

    setState(() {
      recipe = fetchedRecipe;
      recipeIngredient = fetchedIngredients;
    });
    await _fetchImage();
    await _ingredientsDetails();
  }

  _ingredientsDetails() async {
    List<Widget> ll = [];
    for (var ingredient in recipeIngredient) {
      var ing = await ingredientService.getIngredientQuantityBeRecipe(
          widget.recipeKey, ingredient.ingredientId);
      ll.add(Text(
        "- ${ingredientService.getIngredientNameByKey(ingredient.ingredientId)}: $ing",
        style: const TextStyle(
          fontSize: 16,
        ),
      ));
    }
    setState(() {
      list = ll;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        handlePop(didPop, context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(recipe?.name ?? "Loading..."),
          actions: [
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    onTap: () async {
                      bool needsRefresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddRecipeForm(
                                  recipeKey: recipe!.key,
                                )),
                      );
                      if (needsRefresh) {
                        setState(() {
                          _fetchImage();
                        });
                      }
                    },
                    value: localizations!.addEditDeleteModel(
                        localizations.edit, localizations.recipeData),
                    child: Text(localizations.addEditDeleteModel(
                        localizations.edit, localizations.recipeData)),
                  ),
                  PopupMenuItem<String>(
                    onTap: () async {
                      bool needsRefresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    IngredientsDefinitionScreen(
                                      recipeKey: recipe!.key,
                                    )),
                          ) ??
                          false;
                      if (needsRefresh) {
                        setState(() {
                          _getRecipe();
                        });
                      }
                    },
                    value: "Edit Ingredients",
                    child: Text(localizations.ingredientsDefinition),
                  ),
                  PopupMenuItem<String>(
                    onTap: () async {
                      if (recipe != null) {
                        bool needsRefresh = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RecipeSteps(
                                        recipeKey: recipe?.key,
                                      )),
                            ) ??
                            false;
                        if (needsRefresh) {
                          setState(() {
                            _getRecipe();
                          });
                        }
                      }
                    },
                    value: "Edit Steps",
                    child: Text(localizations.recipeSteps),
                  ),
                  PopupMenuItem<String>(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(localizations.holdOn),
                              content: Text(localizations.deleteWarning),
                              actions: <Widget>[
                                TextButton(
                                  style: ButtonStyle(
                                      foregroundColor: WidgetStatePropertyAll(
                                          Theme.of(context).colorScheme.error)),
                                  onPressed: () async {
                                    await recipeService
                                        .deleteRecipe(widget.recipeKey);
                                    if (context.mounted) {
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);
                                    }
                                    if (context.mounted) {
                                      Notifications().showSnackBar(
                                          localizations.addEditDeleteModel(
                                              localizations.delete,
                                              localizations.recipe),
                                          context);
                                    }
                                  },
                                  child: Text(localizations.delete),
                                ),
                                FilledButton(
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Theme.of(context).colorScheme.error)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(localizations.close),
                                ),
                              ],
                            );
                          });
                    },
                    value: "Delete Recipe",
                    child: Text(
                      localizations.addEditDeleteModel(
                          localizations.delete, localizations.recipe),
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ];
              },
            ),
          ],
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
        drawerEdgeDragWidth: MediaQuery.of(context).size.width,
        body: recipe == null || image == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _getRecipe,
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    Stack(fit: StackFit.passthrough, children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 3 / 4,
                        height: MediaQuery.of(context).size.width * 3 / 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(56),
                          child: image,
                        ),
                      ),
                      Positioned(
                        top: 24,
                        right: 24,
                        child: SeasonSelector.getSeasonBadge(recipe!.season),
                      ),
                    ]),
                    const SizedBox(height: 16.0),
                    Text(
                      recipe!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      recipe!.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      localizations!.ingredients,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ...list,
                    const SizedBox(height: 16.0),
                    Text(
                      localizations.steps,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    for (var i = 0; i < recipe!.steps.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${i + 1}. ",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                recipe!.steps[i],
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

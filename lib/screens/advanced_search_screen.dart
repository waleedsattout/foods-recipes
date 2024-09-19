import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:foods/components/drawer.dart';
import 'package:foods/components/ingredients_selection.dart';
import 'package:foods/components/seasons_selector.dart';
import 'package:foods/constants.dart';
import 'package:foods/models/ingredient.dart';
import 'package:foods/models/recipe.dart';
import 'package:foods/models/season_info.dart';
import 'package:foods/providers/shared_data_provider.dart';
import 'package:foods/screens/recipe_details_screen.dart';
import 'package:foods/utils/image_saver.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  SeasonInfo? selectedSeason;
  List<Ingredient> selectedIngredients = [];
  double selectedRating = 5.0;
  List<Ingredient> allIngredients = [];
  List<Recipe> _searchResults = [];
  SharedDataProvider prov = SharedDataProvider();
  AppLocalizations? localization;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    allIngredients = await ingredientService.getAllIngredients();
    _performSearch(limit: 10);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    prov.reset();
  }

  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context);

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          handlePop(didPop, context);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(localization!.advancedSearch),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(context),
              ),
            ],
          ),
          drawer: FoodDrawer(
            screenIndex: getScreenIndex('AdvancedSearch'),
          ),
          drawerEdgeDragWidth: MediaQuery.of(context).size.width,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _searchResults.isNotEmpty
                      ? ListView(
                          children: _searchResults.map((recipe) {
                            return FutureBuilder<Widget>(
                              future: ImageSaver()
                                  .displayImageFromFile(recipe.imageName),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Card.filled(
                                    clipBehavior: Clip.hardEdge,
                                    child: ListTile(
                                      leading:
                                          const CircularProgressIndicator(),
                                      title: Text(recipe.name),
                                      subtitle: Text(
                                        recipe.description,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RecipeDetailsScreen(
                                                    recipeKey: recipe.key,
                                                  )),
                                        );
                                      },
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Card.filled(
                                    clipBehavior: Clip.hardEdge,
                                    child: ListTile(
                                      leading: const Icon(Icons.error),
                                      title: Text(recipe.name),
                                      subtitle: Text(
                                        recipe.description,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RecipeDetailsScreen(
                                                    recipeKey: recipe.key,
                                                  )),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return Card.filled(
                                    clipBehavior: Clip.hardEdge,
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: snapshot.data,
                                      ),
                                      title: Text(recipe.name),
                                      subtitle: Text(
                                        recipe.description,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RecipeDetailsScreen(
                                                    recipeKey: recipe.key,
                                                  )),
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                            );
                          }).toList(),
                        )
                      : Center(child: Text(localization!.noDataFound)),
                ),
              ],
            ),
          ),
        ));
  }

  void _performSearch({int? limit}) async {
    SeasonInfo? season = selectedSeason;
    double rating = selectedRating;
    List<Recipe> results = await recipeService.searchRecipes(
        season: season,
        ingredients: prov.selectedIngredients,
        rating: rating,
        limit: limit);
    setState(() {
      _searchResults = results;
    });
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(localization!.filters),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SeasonSelector.getSeasonSelectionMenu(
                      width: 232,
                      callback: (SeasonInfo e) {
                        setState(() => selectedSeason = e);
                      },
                    ),
                    const SizedBox(height: 16),
                    IngredientsSelection(
                      provider: prov,
                      width: 232,
                    ),
                    Text(
                        '${localization!.rating}: ${selectedRating.toStringAsFixed(1)}'),
                    Slider(
                      value: selectedRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: selectedRating.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() => selectedRating = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(localization!.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    _performSearch();
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                  child: Text(localization!.apply),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

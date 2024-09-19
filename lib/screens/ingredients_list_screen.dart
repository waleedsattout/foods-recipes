import 'package:flutter/material.dart';
import 'package:foods/components/drawer.dart';
import 'package:foods/constants.dart';
import 'package:foods/models/category.dart';
import 'package:foods/models/ingredient.dart';
import 'package:foods/utils/notificatoins.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IngredientsListScreen extends StatefulWidget {
  const IngredientsListScreen({super.key});

  @override
  State<IngredientsListScreen> createState() => _IngredientsListScreenState();
}

class _IngredientsListScreenState extends State<IngredientsListScreen> {
  List<Ingredient> _ingredients = [];
  List<Ingredient> _allIngredients = [];
  final TextEditingController _searchController = TextEditingController();
  List<Category> _categories = [];
  AppLocalizations? localizations;

  @override
  void initState() {
    super.initState();
    _init().then((_) {
      setState(() {});
    });
    _searchController.addListener(_filterIngredients);
  }

  Future<void> _init() async {
    _ingredients = await ingredientService.getAllIngredients();
    _allIngredients = await ingredientService.getAllIngredients();
    _categories = await ingredientService.getAllCategories();
  }

  void _filterIngredients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _ingredients = _allIngredients
          .where((ingredient) => ingredient.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterIngredients);
    _searchController.dispose();
    super.dispose();
  }

  void _onEditIngredient(Ingredient ingredient) {
    Category? selectedCategory;
    ingredientService.getCategoryByKey(ingredient.categoryId).then((e) {
      selectedCategory = e;
    });
    String name = ingredient.name;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations!.addEditDeleteModel(
              localizations!.edit, localizations!.ingredients)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextFormField(
                onChanged: (value) => name = value,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: localizations!.name,
                    labelText: localizations!.name),
                initialValue: ingredient.name,
              ),
              const SizedBox(height: 16.0),
              DropdownMenu<Category>(
                label: Text(localizations!.category),
                initialSelection: selectedCategory,
                dropdownMenuEntries: _categories.map((Category category) {
                  return DropdownMenuEntry<Category>(
                    value: category,
                    label: category.name,
                  );
                }).toList(),
                onSelected: (Category? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                // default dialog width is 280, and contents with padding 24 on both sides.
                width: 232,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations!.close),
            ),
            FilledButton(
              onPressed: () async {
                await ingredientService.editIngredient(ingredient.key,
                    Ingredient(name: name, categoryId: selectedCategory!.key));
                if (context.mounted) {
                  Notifications().showSnackBar(
                      localizations!.modelActionSuccess(
                          localizations!.ingredients, localizations!.edit),
                      context);
                }

                var ingrediets = await ingredientService.getAllIngredients();
                setState(() {
                  _ingredients = ingrediets;
                });
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: Text(localizations!.edit),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    localizations = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        handlePop(didPop, context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations!.ingredientList),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
        drawer: FoodDrawer(
          screenIndex: getScreenIndex("IngredientsList"),
        ),
        drawerEdgeDragWidth: MediaQuery.of(context).size.width,
        body: RefreshIndicator(
          onRefresh: _init,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: localizations!.searchForanIngredient,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: _ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = _ingredients[index];
                      return Card.filled(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: ListTile(
                          title: Text(ingredient.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _onEditIngredient(ingredient),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Theme.of(context).colorScheme.error,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          localizations!.holdOn,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error),
                                        ),
                                        content: Text(localizations!
                                            .deleteIngredientWarning),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            style: ButtonStyle(
                                                foregroundColor:
                                                    WidgetStatePropertyAll(
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .error)),
                                            child: Text(localizations!.close),
                                          ),
                                          FilledButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .error)),
                                            onPressed: () async {
                                              await ingredientService
                                                  .deleteIngredient(
                                                ingredient.key,
                                              );
                                              if (context.mounted) {
                                                Notifications().showSnackBar(
                                                    localizations!
                                                        .modelActionSuccess(
                                                            localizations!
                                                                .ingredients,
                                                            localizations!
                                                                .delete),
                                                    context);
                                              }

                                              var ingrediets =
                                                  await ingredientService
                                                      .getAllIngredients();
                                              setState(() {
                                                _ingredients = ingrediets;
                                              });
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Text(localizations!.delete),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:foods/components/drawer.dart';
import 'package:foods/constants.dart';
import 'package:foods/models/category.dart';
import 'package:foods/models/ingredient.dart';
import 'package:foods/utils/notificatoins.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddIngredientScreen extends StatefulWidget {
  const AddIngredientScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends State<AddIngredientScreen> {
  final TextEditingController _nameController = TextEditingController();
  Category? _selectedCategory;
  List<Category> _categories = [];
  AppLocalizations? localizations;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final categories = await ingredientService.getAllCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _addIngredient() async {
    if (_nameController.text.isNotEmpty && _selectedCategory != null) {
      final newIngredient = Ingredient(
        name: _nameController.text,
        categoryId: _selectedCategory!.key,
      );

      await ingredientService.getAllIngredients().then((e) async {
        var found = e.where((ing) => ing.name == _nameController.text);
        if (found.isNotEmpty) {
          if (context.mounted) {
            Notifications().showSnackBar(
                localizations!.addNewModelError(localizations!.ingredients),
                context);
          }
        } else {
          setState(() {});
          await ingredientService.addIngredient(newIngredient);
          if (context.mounted) {
            Notifications().showSnackBar(
                localizations!.modelActionSuccess(
                    localizations!.ingredients, localizations!.add),
                // ignore: use_build_context_synchronously
                context);
          }

          _nameController.text = '';
        }
      });
    } else {
      if (context.mounted) {
        Notifications()
            .showSnackBar(localizations!.emptySelectionNewIngredient, context);
      }
    }
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
            title: Text(localizations!.addEditDeleteModel(
                localizations!.add, localizations!.ingredients)),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
          drawer: FoodDrawer(
            screenIndex: getScreenIndex("AddIngredient"),
          ),
          drawerEdgeDragWidth: MediaQuery.of(context).size.width,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: localizations!.name,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                (_categories.isEmpty)
                    ? Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                        localizations!.emptyCategoriesError)
                    : DropdownMenu<Category>(
                        initialSelection: _selectedCategory,
                        label: Text(localizations!.category),
                        dropdownMenuEntries:
                            _categories.map((Category category) {
                          return DropdownMenuEntry<Category>(
                            value: category,
                            label: category.name,
                          );
                        }).toList(),
                        onSelected: (Category? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        width: MediaQuery.of(context).size.width - 32,
                      ),
                const SizedBox(height: 16.0),
                if (_categories.isNotEmpty)
                  FilledButton(
                    onPressed: _addIngredient,
                    child: Text(localizations!.addEditDeleteModel(
                        localizations!.add, localizations!.ingredients)),
                  ),
              ],
            ),
          ),
        ));
  }
}

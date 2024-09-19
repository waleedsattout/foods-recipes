import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foods/constants.dart';
import 'package:foods/models/ingredient.dart';
import 'package:foods/models/measurement.dart';
import 'package:foods/models/recipe_ingredient.dart';
import 'package:foods/providers/shared_data_provider.dart';
import 'package:foods/utils/notificatoins.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IngredientsDefinitionScreen extends StatefulWidget {
  final int recipeKey;
  const IngredientsDefinitionScreen({super.key, this.recipeKey = -1});

  @override
  State<StatefulWidget> createState() => _IngredientsDefinitionScreen();
}

class _IngredientsDefinitionScreen extends State<IngredientsDefinitionScreen> {
  List<RecipeIngredient> recipeIngredient = [];
  List<Ingredient> ingredients = [];
  List<Ingredient> allIngredients = [];
  Ingredient? selectedIngrediet;
  bool isDisabled = false;
  List<Measurement> _measurements = [];
  AppLocalizations? localizations;

  @override
  void initState() {
    _fetchMeasurements();
    super.initState();
    if (widget.recipeKey != -1) {
      _fetchData();
    }
  }

  _fetchMeasurements() async {
    var e = await ingredientService.getAllMeasurements();
    setState(() {
      _measurements = e;
    });
  }

  _fetchData() {
    ingredients = [];
    recipeIngredient =
        ingredientService.getAllRecipeIngredients(widget.recipeKey);
    for (var resIng in recipeIngredient) {
      ingredients.add(ingredientService.getIngredient(resIng.ingredientId));
    }
    ingredientService
        .getIngredientsWithout(excludeItems: ingredients)
        .then((value) {
      allIngredients = value;
      setState(() {
        isDisabled = allIngredients.isEmpty;
      });
    });
  }

  Widget ingredietMenu() {
    return DropdownMenu<Ingredient>(
      label: Text(localizations!.ingredients),
      dropdownMenuEntries: allIngredients.map((Ingredient ing) {
        return DropdownMenuEntry<Ingredient>(
          value: ing,
          label: ing.name,
        );
      }).toList(),
      onSelected: (Ingredient? newValue) {
        setState(() {
          selectedIngrediet = newValue;
        });
      },
      // default dialog width is 280, and contents with padding 24 on both sides.
      width: 232,
    );
  }

  Widget headerImage(SharedDataProvider provider) {
    return SizedBox(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.memory(
                      provider.imageData!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(provider.recipeName,
                        style: (Theme.of(context).textTheme.headlineLarge)),
                    const SizedBox(height: 4.0),
                    Text(provider.recipeDescription,
                        style: (Theme.of(context).textTheme.titleMedium)),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    localizations = AppLocalizations.of(context);
    if (widget.recipeKey != -1) {
      SharedDataProvider prov = SharedDataProvider();
      prov.selectedIngredients = ingredients;
      prov.recipeIngredients = recipeIngredient;

      return Scaffold(
          appBar: AppBar(
            title: Text(
              localizations!.editIngredients,
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    ingredientService
                        .editRecipeIngredients(prov.recipeIngredients);

                    if (context.mounted) {
                      Notifications().showSnackBar(
                          localizations!.ingredientsWereEditedSuccessfully,
                          context);
                    }
                    Navigator.pop(context, true);
                  },
                  child: Text(localizations!.submit))
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: isDisabled
                ? () {
                    if (context.mounted) {
                      Notifications().showSnackBar(
                          localizations!.youHaveSelectedAllIngredients,
                          context);
                    }
                  }
                : () {
                    showDialog(
                        context: context,
                        builder: (builder) {
                          return AlertDialog(
                            title: Text(localizations!.newIngredient),
                            content: ingredietMenu(),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(localizations!.cancel)),
                              FilledButton(
                                  onPressed: () {
                                    setState(() {
                                      prov.selectedIngredients
                                          .add(selectedIngrediet!);
                                      prov.addIngredientToRecipe(
                                          RecipeIngredient(
                                              recipeId: widget.recipeKey,
                                              unitId: _measurements[0].key,
                                              quantity: 0,
                                              ingredientId:
                                                  selectedIngrediet!.key));
                                      allIngredients.remove(selectedIngrediet);
                                      isDisabled = allIngredients.isEmpty;
                                      selectedIngrediet = null;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text(localizations!.add))
                            ],
                          );
                        });
                  },
            child: const Icon(Icons.add),
          ),
          drawerEdgeDragWidth: MediaQuery.of(context).size.width,
          body: Center(
            child: SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                isAndroid
                    ? buildAndroidLayout(context, prov)
                    : buildWebDataTable(context, prov),
              ],
            )),
          ));
    } else {
      return (_measurements.isEmpty)
          ? const CircularProgressIndicator()
          : Consumer<SharedDataProvider>(
              builder: (ctx, provider, widget) {
                if (provider.imageData == null ||
                    provider.recipeName == '' ||
                    provider.recipeDescription == '' ||
                    provider.season == provider.seasonError ||
                    provider.selectedIngredients.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                          textAlign: TextAlign.center,
                          localizations!.uncompleteSteps),
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: isAndroid
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: <Widget>[
                      headerImage(provider),
                      const SizedBox(width: 16.0),
                      isAndroid
                          ? buildAndroidLayout(ctx, provider)
                          : buildWebDataTable(ctx, provider),
                    ],
                  ));
                }
              },
            );
    }
  }

  Widget buildWebDataTable(BuildContext context, SharedDataProvider provider) {
    return DataTable(
      dataRowMinHeight: 72,
      dataRowMaxHeight: 72,
      columnSpacing: 16,
      columns: [
        DataColumn(label: Text(localizations!.ingredients)),
        DataColumn(label: Text(localizations!.quantity)),
        DataColumn(label: Text(localizations!.measurement)),
      ],
      rows: provider.selectedIngredients.map((ingredient) {
        return DataRow(cells: [
          DataCell(
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 150),
              child: Text(ingredient.name),
            ),
          ),
          DataCell(
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 150),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 8),
                child: TextFormField(
                  initialValue: (provider.recipeIngredients.isNotEmpty)
                      ? provider.recipeIngredients
                          .firstWhere((q) => q.ingredientId == ingredient.key,
                              orElse: () => RecipeIngredient(
                                  recipeId: widget.recipeKey == -1
                                      ? -999
                                      : widget.recipeKey,
                                  ingredientId: 0,
                                  quantity: 0,
                                  unitId: _measurements[0].key))
                          .quantity
                          .toString()
                      : "",
                  onChanged: (e) {
                    var ings = provider.recipeIngredients
                        .where((ing) => ing.ingredientId == ingredient.key);
                    var val = 0;
                    if (e.isNotEmpty && int.tryParse(e) != null) {
                      val = int.parse(e);
                    }

                    if (ings.isEmpty) {
                      provider.addIngredientToRecipe(RecipeIngredient(
                          recipeId:
                              widget.recipeKey == -1 ? -999 : widget.recipeKey,
                          ingredientId: ingredient.key,
                          quantity: val,
                          unitId: _measurements[0].key));
                    } else {
                      ings.first.quantity = val;
                    }
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: localizations!.quantity,
                    border: const OutlineInputBorder(),
                    floatingLabelAlignment: FloatingLabelAlignment.start,
                    hintText: '2',
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ),
          DataCell(
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 150),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 8),
                child: measurementsDropDown(ingredient.key, provider),
              ),
            ),
          ),
        ]);
      }).toList(),
    );
  }

  Widget buildAndroidLayout(BuildContext context, SharedDataProvider provider) {
    return Column(
      children: provider.selectedIngredients.map((ingredient) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 3 - 12,
                child: widget.recipeKey != -1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ingredient.name,
                          ),
                          IconButton(
                            color: Theme.of(context).colorScheme.error,
                            onPressed: () async {
                              if (ingredients.length == 1) {
                                if (context.mounted) {
                                  Notifications().showSnackBar(
                                      localizations!.oneIngredientDeletion,
                                      context);
                                }
                                return;
                              } else {
                                provider.removeIngredientFromRecipe(ingredient);
                                await ingredientService
                                    .deleteSpecificRecipeIngredient(
                                        widget.recipeKey, ingredient.key);
                                _fetchData();
                              }
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      )
                    : Text(
                        ingredient.name,
                      ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 6 - 12,
                child: TextFormField(
                  initialValue: (provider.recipeIngredients.isNotEmpty)
                      ? provider.recipeIngredients
                          .firstWhere((q) => q.ingredientId == ingredient.key,
                              orElse: () => RecipeIngredient(
                                  recipeId: widget.recipeKey == -1
                                      ? -999
                                      : widget.recipeKey,
                                  ingredientId: 0,
                                  quantity: 0,
                                  unitId: _measurements[0].key))
                          .quantity
                          .toString()
                      : "",
                  onChanged: (e) {
                    var ings = provider.recipeIngredients
                        .where((ing) => ing.ingredientId == ingredient.key);
                    var val = 0;
                    if (e.isNotEmpty && int.tryParse(e) != null) {
                      val = int.parse(e);
                    }
                    if (ings.isEmpty) {
                      provider.addIngredientToRecipe(RecipeIngredient(
                          recipeId:
                              widget.recipeKey == -1 ? -999 : widget.recipeKey,
                          ingredientId: ingredient.key,
                          quantity: val,
                          unitId: _measurements[0].key));
                    } else {
                      ings.first.quantity = val;
                    }
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: localizations!.quantity,
                    border: const OutlineInputBorder(),
                    floatingLabelAlignment: FloatingLabelAlignment.start,
                    hintText: '2',
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width / 3 - 12,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: measurementsDropDown(ingredient.key, provider,
                        recipeKey:
                            widget.recipeKey == -1 ? -999 : widget.recipeKey),
                  ))
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget measurementsDropDown(int ingredientId, SharedDataProvider prov,
      {int recipeKey = -999}) {
    if (_measurements.isEmpty) return const CircularProgressIndicator();
    Measurement? preSelectedMeasurement;
    var iniSel = prov.recipeIngredients.where(
      (e) => e.ingredientId == ingredientId,
    );
    if (iniSel.isNotEmpty) {
      var found =
          _measurements.where((element) => element.key == iniSel.first.unitId);
      if (found.isNotEmpty) preSelectedMeasurement = found.first;
    }
    return DropdownMenu<Measurement>(
      menuHeight: 150,
      width: isAndroid ? 150 : null,
      requestFocusOnTap: true,
      label: Text(
        localizations!.unit,
      ),
      initialSelection: preSelectedMeasurement ?? _measurements[0],
      onSelected: (s) {
        var index = _measurements.indexOf(s!);
        var item = prov.recipeIngredients.where(
          (r) => r.ingredientId == ingredientId,
        );
        if (item.isEmpty) {
          prov.addIngredientToRecipe(RecipeIngredient(
              recipeId: recipeKey,
              ingredientId: ingredientId,
              quantity: 0,
              unitId: index));
        } else {
          item.first.unitId = index;
        }
      },
      dropdownMenuEntries:
          _measurements.map<DropdownMenuEntry<Measurement>>((unit) {
        return DropdownMenuEntry<Measurement>(
          value: unit,
          label: unit.name,
        );
      }).toList(),
    );
  }
}

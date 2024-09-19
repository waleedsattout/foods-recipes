import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:foods/constants.dart';
import 'package:foods/models/ingredient.dart';
import 'package:foods/providers/shared_data_provider.dart';

class IngredientsSelection extends StatefulWidget {
  final SharedDataProvider? provider;
  final double width;
  const IngredientsSelection({super.key, this.provider, this.width = 250});

  @override
  State<StatefulWidget> createState() => _IngredientsSelectionState();
}

class _IngredientsSelectionState extends State<IngredientsSelection> {
  List<Ingredient> allIngredients = [];
  List<Ingredient> ingredients = [];
  late SharedDataProvider prov;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.provider == null) {
      prov = SharedDataProvider();
    } else {
      prov = widget.provider!;
    }

    ingredientService.getAllIngredients().then((e) {
      setState(() {
        allIngredients = e;
        ingredients = e.toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context);

    if (allIngredients.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        child: SizedBox(
          width: widget.width,
          child: Text(
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              localization!.emptyIngredientsError),
        ),
      );
    } else {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
            width: widget.width,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 16),
                child: DropdownMenu<Ingredient>(
                  controller: _controller,
                  enableFilter: true,
                  requestFocusOnTap: true,
                  width: widget.width,
                  label: Text(localization!.ingredients),
                  inputDecorationTheme: const InputDecorationTheme(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                  onSelected: (e) {
                    setState(() {
                      prov.selectIngredient(e!);
                      ingredients.remove(e);
                      _controller.text = '';
                    });
                  },
                  dropdownMenuEntries: ingredients
                      .map<DropdownMenuEntry<Ingredient>>((ing) =>
                          DropdownMenuEntry(value: ing, label: ing.name))
                      .toList(),
                ))),
        ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.width,
              minWidth: widget.width,
              minHeight: widget.width / 2,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Wrap(
                    runSpacing: 8,
                    spacing: 8,
                    children: [ingredientsChips(prov)],
                  ),
                ),
              ),
            ))
      ]);
    }
  }

  Widget ingredientsChips(SharedDataProvider provider) {
    return Wrap(
      runSpacing: 8,
      spacing: 8,
      children: provider.selectedIngredients
          .map((ingredient) => Chip(
              label: Text(ingredient.name),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              onDeleted: () {
                ingredients.add(ingredient);
                provider.removeIngredientFromRecipe(ingredient);
              }))
          .toList(),
    );
  }
}

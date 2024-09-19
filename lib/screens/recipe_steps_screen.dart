import 'package:flutter/material.dart';
import 'package:foods/constants.dart';
import 'package:foods/models/recipe.dart';
import 'package:foods/providers/shared_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecipeSteps extends StatefulWidget {
  final int recipeKey;
  const RecipeSteps({super.key, this.recipeKey = -1});

  @override
  State<StatefulWidget> createState() => _RecipeSteps();
}

class _RecipeSteps extends State<RecipeSteps> {
  final _stepsController = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool isEditing = false;
  int indexOfEditing = -1;
  Recipe? recipe;
  AppLocalizations? localizations;

  @override
  void initState() {
    super.initState();
    if (widget.recipeKey != -1) {
      _fetchData();
    }
    _focus.requestFocus();
  }

  _fetchData() async {
    recipe = await recipeService.getRecipeData(widget.recipeKey);
    setState(() {});
  }

  @override
  void dispose() {
    _stepsController.dispose();
    super.dispose();
  }

  List<Widget> body(SharedDataProvider provider) {
    List<Widget> list = [
      ListView.builder(
        shrinkWrap: true,
        itemCount: provider.steps.length,
        itemBuilder: (context, index) {
          return ListTile(
            tileColor: indexOfEditing == index
                ? Theme.of(context).colorScheme.surfaceContainer
                : Colors.transparent,
            title: Text(
                "${localizations!.step} ${index + 1}: ${provider.steps[index]}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                      indexOfEditing = index;
                    });
                    _stepsController.text = provider.steps[index];
                    _focus.requestFocus();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  style: ButtonStyle(
                      iconColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.error)),
                  onPressed: () {
                    setState(() {
                      provider.removeStep(index);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _stepsController,
                focusNode: _focus,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: localizations!.step,
                  filled: true,
                  hintText: isAndroid
                      ? localizations!.stepHintShort
                      : localizations!.stepHintLong,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                final step = _stepsController.text.trim();
                if (step.isNotEmpty) {
                  setState(() {
                    if (isEditing) {
                      provider.updateStep(indexOfEditing, step);
                    } else {
                      provider.addStep(step);
                      _stepsController.text = "";
                    }

                    isEditing = false;
                    indexOfEditing = -1;
                    _stepsController.text = "";
                    _focus.requestFocus();
                  });
                }
              },
              child: Text(isEditing ? localizations!.edit : localizations!.add),
            ),
          ],
        ),
      )
    ];

    return (widget.recipeKey != -1) ? list.reversed.toList() : list;
  }

  @override
  Widget build(BuildContext context) {
    localizations = AppLocalizations.of(context);
    if (widget.recipeKey != -1) {
      SharedDataProvider prov = SharedDataProvider();
      if (recipe != null) prov.steps = recipe!.steps;
      return Scaffold(
          appBar: AppBar(
            title: Text(localizations!
                .addEditDeleteModel(localizations!.edit, localizations!.steps)),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    recipe!.steps = prov.steps;
                    await recipeService.editRecipeData(
                        widget.recipeKey, recipe!, null);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(
                    localizations!.submit,
                  ))
            ],
          ),
          drawerEdgeDragWidth: MediaQuery.of(context).size.width,
          body: SingleChildScrollView(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: body(prov),
                )),
          ));
    } else {
      return Consumer<SharedDataProvider>(
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
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(provider.recipeName,
                                          style: (Theme.of(context)
                                              .textTheme
                                              .headlineLarge)),
                                      const SizedBox(height: 4.0),
                                      Text(provider.recipeDescription,
                                          style: (Theme.of(context)
                                              .textTheme
                                              .titleMedium)),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ),
                      const SizedBox(width: 16.0),
                      ...body(provider),
                    ],
                  )),
            );
          }
        },
      );
    }
  }
}

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:foods/components/ingredients_selection.dart';
import 'package:foods/components/seasons_selector.dart';
import 'package:foods/constants.dart';
import 'package:foods/models/ingredient.dart';
import 'package:foods/models/recipe.dart';
import 'package:foods/providers/shared_data_provider.dart';
import 'package:foods/utils/image_saver.dart';
import 'package:foods/utils/notificatoins.dart';
import 'package:provider/provider.dart';

class AddRecipeForm extends StatefulWidget {
  final int recipeKey;
  const AddRecipeForm({super.key, this.recipeKey = -1});

  @override
  State<AddRecipeForm> createState() => _AddRecipeFormState();
}

class _AddRecipeFormState extends State<AddRecipeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImageSaver _imageSaver = ImageSaver();
  bool isLoaded = false;
  List<Ingredient>? ingredients;
  List<Ingredient>? allIngredients;
  Recipe recipe = Recipe(
      name: '',
      description: '',
      season: '',
      steps: [],
      imageName: '',
      rating: 0);
  Uint8List? image;
  bool nullImage = false;
  final focusNode1 = FocusNode();
  final focusNode2 = FocusNode();

  AppLocalizations? localization;

  @override
  void initState() {
    if (widget.recipeKey != -1) {
      _fetchRecipeData();
    }

    ingredientService.getAllIngredients().then((e) {
      setState(() {
        ingredients = e;
        allIngredients = e.toList();
      });
    });
    super.initState();
  }

  Future<void> _fetchRecipeData() async {
    var fetchedIngredients = await ingredientService.getAllIngredients();
    recipe = await recipeService.getRecipeData(widget.recipeKey);
    image = await _imageSaver.getImageData(recipe.imageName).then((value) {
      if (value == null) nullImage = true;
      return value;
    });
    setState(() {
      ingredients = fetchedIngredients;
    });
  }

  Future<void> _pickAndSaveImage(SharedDataProvider provider) async {
    await _imageSaver.pickImage().then((img) {
      image = img;
      provider.setImageData(img!);
      provider.imageName = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> body(SharedDataProvider prov) {
    return [
      SizedBox(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 8),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: SizedBox(
                    width: 250,
                    height: 250,
                    child: (prov.imageData == null && recipe.imageName == "")
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              borderRadius: BorderRadius.circular(48),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 16.0),
                                Text(
                                  localization!.yourImageWillShowUpHere,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16.0),
                                TextButton(
                                  onPressed: () {
                                    _pickAndSaveImage(prov);
                                  },
                                  child: Text(localization!.pickImage),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                                (widget.recipeKey != -1)
                                    ? (image == null)
                                        ? const CircularProgressIndicator()
                                        : Image.memory(
                                            image!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          )
                                    : Image.memory(
                                        prov.imageData!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                Positioned(
                                    top: 16,
                                    right: 16,
                                    child: IconButton(
                                      iconSize: 24,
                                      icon: const Icon(Icons.edit),
                                      style: ButtonStyle(
                                          iconColor: WidgetStatePropertyAll(
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .surfaceContainer)),
                                      onPressed: () {
                                        _pickAndSaveImage(prov);
                                      },
                                    ))
                              ]))),
          )),
      FocusScope(
        child: SizedBox(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 8),
            child: TextFormField(
              textInputAction: TextInputAction.next,
              initialValue:
                  prov.recipeName == "" ? recipe.name : prov.recipeName,
              onChanged: (e) {
                prov.saveRecipeName(e);
                recipe.name = e;
              },
              focusNode: focusNode1,
              onEditingComplete: () => focusNode2.requestFocus(),
              decoration: InputDecoration(
                labelText: localization!.name,
                border: const OutlineInputBorder(),
                floatingLabelAlignment: FloatingLabelAlignment.start,
                hintText: localization!.bechamel,
              ),
            ),
          ),
        ),
      ),
      FocusScope(
        child: SizedBox(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              initialValue: prov.recipeDescription == ""
                  ? recipe.description
                  : prov.recipeDescription,
              onChanged: (e) {
                prov.saveRecipeDescription(e);
                recipe.description = e;
              },
              maxLines: 4,
              decoration: InputDecoration(
                  labelText: localization!.description,
                  border: const OutlineInputBorder(),
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                  hintText: localization!.bechamelDescription),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return localization!.enterFewWordsForYourRecipe;
                }
                return null;
              },
              focusNode: focusNode2,
            ),
          ),
        ),
      ),
      SizedBox(
          width: 250,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
              child: recipe.season != ''
                  ? SeasonSelector.getSeasonSelectionMenu(
                      name: recipe.season,
                      callback: (e) {
                        recipe.season = e.name;
                      })
                  : SeasonSelector.getSeasonSelectionMenu(provider: prov))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context);
    return (allIngredients == null)
        ? const CircularProgressIndicator()
        : Consumer<SharedDataProvider>(builder: (b, prov, w) {
            sharedDataProvider.setProv(prov);
            if (widget.recipeKey != -1) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(localization!.editRecipe),
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ),
                drawerEdgeDragWidth: MediaQuery.of(context).size.width,
                body: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: body(prov),
                    ),
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    if (recipe.name == '' ||
                        recipe.description == '' ||
                        recipe.imageName == '' ||
                        recipe.season == '') {
                      if (context.mounted) {
                        Notifications().showSnackBar(
                            "Something went wrong, try again.", context);
                      }
                    } else {
                      recipeService.editRecipeData(recipe.key, recipe, image);
                      prov.reset();
                      Navigator.pop(context, true);
                      if (context.mounted) {
                        Notifications().showSnackBar(
                            localization!.recipeWasEditedSuccessfully, context);
                      }
                    }
                  },
                  child: const Icon(Icons.edit),
                ),
              );
            } else {
              return Consumer<SharedDataProvider>(builder: (b, prov, w) {
                return Center(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: body(prov) +
                              [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                        '${localization!.rating}: ${prov.rating.toStringAsFixed(1)}'),
                                    Slider(
                                      value: prov.rating,
                                      min: 0,
                                      max: 5,
                                      divisions: 10,
                                      label: prov.rating.toStringAsFixed(1),
                                      onChanged: (value) {
                                        setState(() {
                                          prov.rating = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                IngredientsSelection(
                                  provider: prov,
                                  width: 232,
                                )
                              ],
                        ),
                      ),
                    ),
                  ),
                );
              });
            }
          });
  }
}

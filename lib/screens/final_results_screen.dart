import 'package:flutter/material.dart';
import 'package:foods/components/seasons_selector.dart';
import 'package:foods/constants.dart';
import 'package:foods/providers/shared_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FinalResultsScreen extends StatefulWidget {
  const FinalResultsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _FinalResultsScreen();
}

class _FinalResultsScreen extends State<FinalResultsScreen> {
  AppLocalizations? localizations;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    localizations = AppLocalizations.of(context);
    return Consumer<SharedDataProvider>(builder: (b, prov, w) {
      if (prov.imageData == null ||
          prov.recipeName == '' ||
          prov.recipeDescription == '' ||
          prov.season == prov.seasonError ||
          prov.selectedIngredients.isEmpty ||
          prov.steps.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              textAlign: TextAlign.center,
              localizations!.uncompleteSteps,
            ),
          ),
        );
      } else {
        return Stack(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(children: [
                      Card.filled(
                        elevation: 5,
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          child: Stack(
                            children: [
                              isAndroid
                                  ? SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: contents(prov),
                                      ))
                                  : SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: contents(prov),
                                      )),
                              Positioned(
                                top: 8.0,
                                right: 8.0,
                                child: SeasonSelector.getSeasonBadge(
                                    prov.season.name),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  )),
            ),
            Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    prov.submitRecipe(context);
                    setState(() {});
                  },
                  label: Text(localizations!.submit),
                  icon: const Icon(Icons.add),
                ))
          ],
        );
      }
    });
  }

  List<Widget> contents(SharedDataProvider prov) {
    var width = isAndroid
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width / 2 - 22;
    return [
      ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: SizedBox(
          height: width,
          width: width,
          child: Image.memory(
            prov.imageData!,
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(width: 8.0),
      Expanded(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 16, vertical: isAndroid ? 8 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                prov.recipeName,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(fontSize: 24.0),
              ),
              Text(
                prov.recipeDescription,
              ),
              const Divider(),
              Text(
                localizations!.ingredients,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                children: prov.selectedIngredients
                    .map((ingredient) => Text(
                        '${ingredient.name}${(prov.selectedIngredients.last == ingredient) ? '.' : ', '}'))
                    .toList(),
              ),
              const Divider(),
              Text(
                '${localizations!.steps}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: prov.steps.length,
                itemBuilder: (context, index) => Text(
                  '${localizations!.step} ${index + 1}: ${prov.steps[index]}',
                ),
              ),
            ],
          ),
        ),
      )
    ];
  }
}

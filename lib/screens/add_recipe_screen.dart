import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foods/components/drawer.dart';
import 'package:foods/constants.dart';
import 'package:foods/screens/add_recipe_form_screen.dart';
import 'package:foods/screens/final_results_screen.dart';
import 'package:foods/screens/ingredients_definition_screen.dart';
import 'package:foods/screens/recipe_steps_screen.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddRecipeScreen();
}

class _AddRecipeScreen extends State<AddRecipeScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    sharedDataProvider.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        handlePop(didPop, context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(localization!.addRecipe),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          bottom: TabBar(
            tabAlignment: isAndroid ? TabAlignment.start : null,
            controller: _tabController,
            isScrollable: isAndroid,
            tabs: <Widget>[
              Tab(
                text: localization.recipeData,
              ),
              Tab(
                text: localization.ingredientsDefinition,
              ),
              Tab(
                text: localization.recipeSteps,
              ),
              Tab(
                text: localization.finalResult,
              ),
            ],
          ),
        ),
        drawer: FoodDrawer(
          screenIndex: getScreenIndex("AddRecipe"),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const <Widget>[
            AddRecipeForm(),
            IngredientsDefinitionScreen(),
            RecipeSteps(),
            FinalResultsScreen(),
          ],
        ),
      ),
    );
  }
}

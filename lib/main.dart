import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:foods/hive/hive_boxes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foods/providers/shared_data_provider.dart';
import 'package:foods/constants.dart';
import 'package:foods/screens/add_category_screen.dart';
import 'package:foods/screens/add_ingredient_screen.dart';
import 'package:foods/screens/add_recipe_screen.dart';
import 'package:foods/screens/advanced_search_screen.dart';
import 'package:foods/screens/categoris_list_screen.dart';
import 'package:foods/screens/home_screen.dart';
import 'package:foods/screens/ingredients_list_screen.dart';
import 'package:foods/screens/manage_measurements_units_screen.dart';
import 'package:foods/utils/notificatoins.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initConstants();
  await Notifications().init();
  await initHive();
  runApp(ChangeNotifierProvider<SharedDataProvider>(
    create: (context) => SharedDataProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    flipStatusBarBackgroundColor(false);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        initialRoute: "home",
        routes: {
          "home": (context) => const HomeScreen(),
          "advancedSearch": (context) => const AdvancedSearchScreen(),
          "addRecipe": (context) => const AddRecipeScreen(),
          "addIngredient": (context) => const AddIngredientScreen(),
          "ingredientList": (context) => const IngredientsListScreen(),
          "addCategory": (context) => const AddCategoryScreen(),
          "CategoriesList": (context) => const CategoriesListScreen(),
          "measurements": (context) => const ManageMeasurementUnits(),
        },
        title: 'Foods Recipes',
        theme: ThemeData(
          colorScheme: colorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(colorScheme: colorSchemeDark, useMaterial3: true),
        home: const HomeScreen());
  }
}

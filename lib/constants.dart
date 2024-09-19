import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foods/providers/shared_data_provider.dart';
import 'package:foods/services/ingredient_service.dart';
import 'package:foods/services/recipe_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isWebMobile = false;
bool isAndroid = false;
RecipeService recipeService = RecipeService();
IngredientService ingredientService = IngredientService();
SharedDataProvider sharedDataProvider = SharedDataProvider();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.green);
ColorScheme colorSchemeDark =
    ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark);
SharedPreferences? sharedPreferences;

Future initConstants() async {
  isWebMobile = kIsWeb;
  if (!isWebMobile) {
    isAndroid = Platform.isAndroid;
  }
}

class Screens {
  Screens(this.index, this.label, this.text, this.icon, this.selectedIcon,
      {this.hide = false});

  final String label;
  final String text;
  final Widget icon;
  final Widget selectedIcon;
  final int index;
  bool hide;
}

List<Screens> destinations = <Screens>[
  Screens(0, 'Home', 'Home', const Icon(Icons.home_outlined),
      const Icon(Icons.home)),
  Screens(
    1,
    'AdvancedSearch',
    'Advanced Search',
    const Icon(Icons.search),
    const Icon(Icons.search),
  ),
  Screens(
    2,
    'AddRecipe',
    'Add a Recipe',
    SvgPicture.asset(
      "assets/images/add_document.svg",
      width: 24.0,
      height: 24.0,
    ),
    SvgPicture.asset(
      "assets/images/filled_add_document.svg",
      width: 24.0,
      height: 24.0,
    ),
  ),
  Screens(
      3,
      'AddIngredient',
      'Add an Ingredient',
      SvgPicture.asset(
        "assets/images/ingredient.svg",
        width: 24.0,
        height: 24.0,
      ),
      SvgPicture.asset(
        "assets/images/ingredient_outlined.svg",
        width: 24.0,
        height: 24.0,
      ),
      hide: false),
  Screens(4, 'IngredientsList', 'Ingredients List', const Icon(Icons.list),
      const Icon(Icons.list),
      hide: false),
  Screens(5, 'AddCategory', 'Add a Category',
      const Icon(Icons.add_circle_outlined), const Icon(Icons.add_circle),
      hide: false),
  Screens(6, 'CategoriesList', 'Categories List', const Icon(Icons.list),
      const Icon(Icons.list),
      hide: false),
  Screens(7, 'ManageMeasurements', 'Manage Measurements',
      const Icon(Icons.scale_outlined), const Icon(Icons.scale),
      hide: false),
  Screens(100, 'Details', 'Details', const Icon(Icons.settings_outlined),
      const Icon(Icons.settings),
      hide: true),
];
List<Screens> destinationsArabic = <Screens>[
  Screens(0, 'Home', 'الصفحة الرئيسية', const Icon(Icons.home_outlined),
      const Icon(Icons.home)),
  Screens(
    1,
    'AdvancedSearch',
    'بحث متقدم',
    const Icon(Icons.search),
    const Icon(Icons.search),
  ),
  Screens(
    2,
    'AddRecipe',
    'إضافة وصفة',
    SvgPicture.asset(
      "assets/images/add_document.svg",
      width: 24.0,
      height: 24.0,
    ),
    SvgPicture.asset(
      "assets/images/filled_add_document.svg",
      width: 24.0,
      height: 24.0,
    ),
  ),
  Screens(
      3,
      'AddIngredient',
      'إضافة مكون',
      SvgPicture.asset(
        "assets/images/ingredient.svg",
        width: 24.0,
        height: 24.0,
      ),
      SvgPicture.asset(
        "assets/images/ingredient_outlined.svg",
        width: 24.0,
        height: 24.0,
      ),
      hide: false),
  Screens(4, 'IngredientsList', 'قائمة المكونات', const Icon(Icons.list),
      const Icon(Icons.list),
      hide: false),
  Screens(5, 'AddCategory', 'إضافة صنف', const Icon(Icons.add_circle_outlined),
      const Icon(Icons.add_circle),
      hide: false),
  Screens(6, 'CategoriesList', 'قائمة الأصناف', const Icon(Icons.list),
      const Icon(Icons.list),
      hide: false),
  Screens(7, 'ManageMeasurements', 'إدارة المقاييس',
      const Icon(Icons.scale_outlined), const Icon(Icons.scale),
      hide: false),
  Screens(100, 'Details', 'التفاصيل', const Icon(Icons.settings_outlined),
      const Icon(Icons.settings),
      hide: true),
];

int getScreenIndex(String label) =>
    destinations.where((e) => e.label == label).first.index;

void flipStatusBarBackgroundColor(bool isSearching) {
  if (isSearching) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: colorScheme.surfaceContainerHigh,
        statusBarIconBrightness: Brightness.dark));
  } else {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: colorScheme.surface,
        statusBarIconBrightness: Brightness.dark));
  }
}

void handlePop(didPop, context) async {
  if (didPop) {
    return;
  }
  Navigator.pushNamedAndRemoveUntil(
      context, "home", ModalRoute.withName("home"));
}

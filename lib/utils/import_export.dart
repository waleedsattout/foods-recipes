import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foods/hive/hive_boxes.dart';
import 'package:foods/models/category.dart';
import 'package:foods/models/measurement.dart';
import 'package:foods/models/recipe.dart';
import 'package:foods/models/recipe_ingredient.dart';
import 'package:foods/utils/notificatoins.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;
import 'package:foods/constants.dart';
import 'package:foods/models/ingredient.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';

class ImportExport {
  static Future<String> createFolder() async {
    final path = Directory("/storage/emulated/0/Foods");
    var status = await Permission.storage.status;

    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      if (await path.exists()) {
        return path.path;
      } else {
        await path.create(recursive: true);
        return path.path;
      }
    } else {
      throw Exception('Storage permission denied');
    }
  }

  static Future<void> exportHiveDataToJSON(String boxName) async {
    final Box box;
    switch (boxName) {
      case HiveBoxes.categoriesBox:
        box = Hive.box<Category>(boxName);
        break;
      case HiveBoxes.images:
        box = Hive.box<Image>(boxName);
        break;
      case HiveBoxes.ingredientsBox:
        box = Hive.box<Ingredient>(boxName);
        break;
      case HiveBoxes.measurementBox:
        box = Hive.box<Measurement>(boxName);
        break;
      case HiveBoxes.recipeIngredientsBox:
        box = Hive.box<RecipeIngredient>(boxName);
        break;
      case HiveBoxes.recipesBox:
        box = Hive.box<Recipe>(boxName);
        break;

      default:
        box = Hive.box<Recipe>(boxName);
        break;
    }

    final data = box.values.map((item) => item.toJson()).toList();
    final jsonData = jsonEncode(data);
    if (isAndroid) {
      final directory = Directory("/storage/emulated/0/Foods");
      if (!await directory.exists()) {
        await createFolder();
      }
      final file = File('${directory.path}/$boxName.json');
      try {
        await file.writeAsBytes(utf8.encode(jsonData));
      } catch (e) {
        throw Exception('Cannot write file: $e');
      }
    } else {
      final bytes = utf8.encode(jsonData);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "$boxName.json")
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  // static Future<void> importHiveDataFromJSON(String boxName) async {
  //   Type getBoxType(String boxName) {
  //     switch (boxName) {
  //       case HiveBoxes.categoriesBox:
  //         return Category;
  //       case HiveBoxes.images:
  //         return Image;
  //       case HiveBoxes.ingredientsBox:
  //         return Ingredient;
  //       case HiveBoxes.measurementBox:
  //         return Measurement;
  //       case HiveBoxes.recipeIngredientsBox:
  //         return RecipeIngredient;
  //       case HiveBoxes.recipesBox:
  //         return Recipe;
  //       default:
  //         return Recipe;
  //     }
  //   }

  //   Type type = getBoxType(boxName);
  //   final result = await FilePicker.platform.pickFiles(allowMultiple: false);
  //   if (result != null) {
  //     final file = File(result.files.single.path!);

  //     if (await file.exists()) {
  //       final jsonData = await file.readAsString();
  //       final List<dynamic> dataList = jsonDecode(jsonData);
  //       final box = Hive.box<type>(boxName);

  //       for (var item in dataList) {
  //         final dynamic newItem = type.fromJson(item as Map<String, dynamic>);
  //         await box.add(newItem);
  //       }
  //       for (var item in dataList) {
  //         final recipeIngredient =
  //             RecipeIngredient.fromJson(item as Map<String, dynamic>);
  //         await box.add(recipeIngredient);
  //       }
  //     } else {
  //       Notifications().showSnackBar("You did not select a file.", null);
  //     }
  //   }
  // }

  static Future<void> importHiveDataFromJSON(String boxName) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      final file = File(result.files.single.path!);

      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final List<dynamic> dataList = jsonDecode(jsonData);

        Box? box;
        dynamic Function(Map<String, dynamic>) fromJson = (_) {};

        switch (boxName) {
          case HiveBoxes.categoriesBox:
            box = Hive.box<Category>(boxName);
            fromJson = (json) => Category.fromJson(json);
            break;
          case HiveBoxes.images:
            break;
          case HiveBoxes.ingredientsBox:
            box = Hive.box<Ingredient>(boxName);
            fromJson = (json) => Ingredient.fromJson(json);
            break;
          case HiveBoxes.measurementBox:
            box = Hive.box<Measurement>(boxName);
            fromJson = (json) => Measurement.fromJson(json);
            break;
          case HiveBoxes.recipeIngredientsBox:
            box = Hive.box<RecipeIngredient>(boxName);
            fromJson = (json) => RecipeIngredient.fromJson(json);
            break;
          case HiveBoxes.recipesBox:
            box = Hive.box<Recipe>(boxName);
            fromJson = (json) => Recipe.fromJson(json);
            break;
          default:
            box = Hive.box<Recipe>(boxName);
            fromJson = (json) => Recipe.fromJson(json);
            break;
        }

        for (var item in dataList) {
          final object = fromJson(item as Map<String, dynamic>);
          await box!.add(object);
        }
      } else {
        Notifications().showSnackBar(
            "You did not select a file.", context as BuildContext);
      }
    }
  }
}

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:foods/components/drawer.dart';
import 'package:foods/hive/hive_boxes.dart';
import 'package:foods/utils/import_export.dart';

extension HiveBoxNames on HiveBoxes {
  static const Map<String, String> friendlyNames = {
    HiveBoxes.recipesBox: 'Recipes',
    HiveBoxes.ingredientsBox: 'Ingredients',
    HiveBoxes.categoriesBox: 'Categories',
    HiveBoxes.recipeIngredientsBox: 'Recipe Ingredients',
    HiveBoxes.measurementBox: 'Measurements',
    HiveBoxes.images: 'Images',
  };

  static List<String> get allBoxes => friendlyNames.keys.toList();

  static String getFriendlyName(String boxName) {
    return friendlyNames[boxName] ?? boxName;
  }
}

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  String selectedBox = HiveBoxes.recipesBox;

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.importExport),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      drawer: const FoodDrawer(
        screenIndex: 8,
      ),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: localizations.exportData,
              dropdownValue: selectedBox,
              onChanged: (value) => setState(() => selectedBox = value!),
              onButtonPressed: () async {
                await ImportExport.exportHiveDataToJSON(selectedBox);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.exportSuccess)),
                  );
                }
              },
            ),
            const SizedBox(height: 16.0),
            _buildSectionCard(
              title: localizations.importData,
              dropdownValue: selectedBox,
              onChanged: (value) => setState(() => selectedBox = value!),
              onButtonPressed: () async {
                await ImportExport.importHiveDataFromJSON(selectedBox);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.importSuccess)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String dropdownValue,
    required ValueChanged<String?> onChanged,
    required VoidCallback onButtonPressed,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    items: HiveBoxNames.allBoxes.map((boxName) {
                      return DropdownMenuItem(
                        value: boxName,
                        child: Text(HiveBoxNames.getFriendlyName(boxName)),
                      );
                    }).toList(),
                    onChanged: onChanged,
                    isExpanded: true,
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: onButtonPressed,
                  child: Text(title.split(' ')[0]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

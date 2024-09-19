import 'package:flutter/material.dart';
import 'package:foods/components/drawer.dart';
import 'package:foods/constants.dart';
import 'package:foods/models/category.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foods/utils/notificatoins.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  AppLocalizations? localizations;

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      String categoryName = _nameController.text;

      var list = await ingredientService.searchCategories(categoryName);
      var found = list.firstWhere((e) => e.name == categoryName, orElse: () {
        return Category(name: "error");
      });
      if (found.name != "error" && context.mounted) {
        Notifications().showSnackBar(
            localizations!.addNewModelError(localizations!.category),
            // ignore: use_build_context_synchronously
            context);
      } else {
        await ingredientService.addCategory(Category(name: categoryName));
        Notifications().showSnackBar(
            localizations!.modelActionSuccess(
                localizations!.category, localizations!.add),
            // ignore: use_build_context_synchronously
            context);
        _nameController.clear();
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    localizations = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
        onPopInvoked: (didPop) {
          handlePop(didPop, context);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(localizations!.addEditDeleteModel(
                localizations!.add, localizations!.category)),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
          drawer: FoodDrawer(
            screenIndex: getScreenIndex("AddCategory"),
          ),
          drawerEdgeDragWidth: MediaQuery.of(context).size.width,
          body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: localizations!.category,
                        hintText: localizations!.meats,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    FilledButton(
                      onPressed: _saveCategory,
                      child: Text(localizations!.submit),
                    ),
                  ],
                ),
              )),
        ));
  }
}

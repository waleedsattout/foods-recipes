import 'package:flutter/material.dart';
import 'package:foods/components/drawer.dart';
import 'package:foods/constants.dart';
import 'package:foods/models/category.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CategoriesScreeListnState();
}

class _CategoriesScreeListnState extends State<CategoriesListScreen> {
  List<Category> _filteredCategories = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init().then((_) {
      setState(() {});
    });
    _searchController.addListener(_filterCategories);
  }

  Future<void> _init() async {
    _filteredCategories = await ingredientService.getAllCategories();
  }

  Future<void> _filterCategories() async {
    final query = _searchController.text.toLowerCase();
    await ingredientService.searchCategories(query).then(
      (value) {
        setState(() {
          _filteredCategories = value;
        });
      },
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCategories);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        handlePop(didPop, context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations!.categoryList),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
        drawer: FoodDrawer(
          screenIndex: getScreenIndex("CategoriesList"),
        ),
        drawerEdgeDragWidth: MediaQuery.of(context).size.width,
        body: RefreshIndicator(
          onRefresh: _init,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: localizations.search,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      return Card.filled(
                          clipBehavior: Clip.hardEdge,
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          child: ListTile(
                            title: TextFormField(
                              initialValue: category.name,
                              onChanged: (value) async {
                                await ingredientService.editCategory(
                                    category.key, Category(name: value));
                                _filteredCategories =
                                    await ingredientService.getAllCategories();
                                setState(() {});
                              },
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              color: Theme.of(context).colorScheme.error,
                              onPressed: () async {
                                await ingredientService
                                    .deleteCategory(category.key);
                                _filteredCategories =
                                    await ingredientService.getAllCategories();
                                setState(() {});
                              },
                            ),
                            onTap: () {},
                          ));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

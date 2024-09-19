import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'package:foods/utils/image_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:foods/components/drawer.dart';
import 'package:foods/components/seasons_selector.dart';
import 'package:foods/constants.dart';
import 'package:foods/models/recipe.dart';
import 'package:foods/screens/recipe_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreen();
  }
}

class _HomeScreen extends State<HomeScreen> {
  final SearchController controller = SearchController();
  int screenIndex = 0;
  late bool showNavigationDrawer;
  Future<List<Widget>>? _gridFuture;
  Directory? directory;
  List<Image> images = [];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((e) {
      sharedPreferences = e;
      if (sharedPreferences!.get("locale") == null) {
        sharedPreferences!
            .setString("locale", Localizations.localeOf(context).toString());
      }
    });
    _loadGrid();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (isAndroid) {
      await Permission.storage.request();
      directory = await getExternalStorageDirectory();
    }
  }

  Future<void> _loadGrid() async {
    final recipes = await recipeService.getAllRecipes();
    if (recipes.isNotEmpty) {
      if (mounted) {
        final gridItems = await createGrid(context, recipes);
        setState(() {
          _gridFuture = Future.value(gridItems);
        });
      } else {
        setState(() {
          _gridFuture = Future.value([]);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context);
    return Scaffold(
        drawerEdgeDragWidth: MediaQuery.of(context).size.width,
        drawer: FoodDrawer(
          screenIndex: getScreenIndex("Home"),
        ),
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Padding(
              padding: isWebMobile
                  ? const EdgeInsets.all(17.5)
                  : const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: SearchAnchor(
                viewHintText: localization!.bechamel,
                isFullScreen: false,
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    elevation: const WidgetStatePropertyAll<double?>(0),
                    controller: controller,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (_) {
                      controller.openView();
                    },
                    leading: DrawerButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    hintText: localization.searchForaRecipe,
                    trailing: [
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                      ),
                    ],
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) async {
                  List<Recipe> filteredData =
                      (await recipeService.getAllRecipes())
                          .where((e) => e.name.contains(controller.text))
                          .toList();
                  var widgetList = filteredData.map((recipe) {
                    return ListTile(
                      leading: SizedBox(
                        width: 40,
                        height: 40,
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(999)),
                            child: images.isEmpty
                                ? const Icon(Icons.restaurant_menu)
                                : images[filteredData.indexOf(recipe)]),
                      ),
                      title: Text(recipe.name),
                      subtitle: Text(
                        recipe.description,
                        style: const TextStyle(overflow: TextOverflow.ellipsis),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: '/home'),
                            builder: (context) => PopScope(
                              onPopInvoked: (b) async {
                                return Navigator.popUntil(
                                    context, ModalRoute.withName('/home'));
                              },
                              child: RecipeDetailsScreen(
                                recipeKey: recipe.key,
                              ),
                            ),
                          ),
                        );
                        setState(() {
                          _loadGrid();
                        });
                      },
                    );
                  }).toList();
                  return widgetList;
                },
              ),
            )),
        body: RefreshIndicator(
          onRefresh: _loadGrid,
          child: FutureBuilder<List<Widget>>(
            future: _gridFuture,
            initialData: const [],
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final dataList = snapshot.data!;
                if (dataList.isEmpty) {
                  return Center(child: Text(localization.noDataFound));
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: StaggeredGrid.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: isAndroid ? 0 : 12,
                      crossAxisSpacing: isAndroid ? 0 : 12,
                      children: dataList,
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }

  Future<List<Widget>> createGrid(
      BuildContext context, List<Recipe> recipes) async {
    final List<Widget> list = [];
    int recipeIndex = 0;
    images = [];

    bool breakNow = false;
    for (var i = 0; i < sizes.length; i++) {
      final currentSizes = sizes[i];
      for (var j = 0; j < currentSizes.length; j++) {
        late List size;
        if (currentSizes[j] is List) {
          size = currentSizes[j] as List;
        } else {
          size = currentSizes;
        }

        if (recipeIndex >= recipes.length) {
          breakNow = true;
          break;
        }

        final dataItem = recipes[recipeIndex++];
        var image = await ImageSaver().displayImageFromFile(dataItem.imageName);
        images.add(image);
        final widget = StaggeredGridTile.count(
          crossAxisCellCount: size[0],
          mainAxisCellCount: size[1],
          child: Card.outlined(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RecipeDetailsScreen(recipeKey: dataItem.key),
                  ),
                );
                setState(() {});
              },
              child: Stack(
                children: [
                  /* Big card 4*2 */
                  if (size[0] > 2) ...[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: isAndroid
                                    ? SizedBox(
                                        height: (context.mounted)
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                20
                                            : 350,
                                        width: (context.mounted)
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                20
                                            : 350,
                                        child: image)
                                    : SizedBox(
                                        height: (context.mounted)
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                22
                                            : 350,
                                        width: (context.mounted)
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                22
                                            : 350,
                                        child: await ImageSaver()
                                            .displayImageFromFile(
                                                dataItem.imageName),
                                      )),
                            const SizedBox(width: 8.0),
                            Column(
                              children: [
                                Text(dataItem.name),
                                Text(dataItem.description),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    if (isAndroid)
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: SeasonSelector.getSeasonBadge(dataItem.season),
                      ),
                    /* Medium card 2*2 */
                  ] else if (size[0] >= 2 && size[1] >= 2) ...[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            clipBehavior: Clip.hardEdge,
                            child: isAndroid
                                ? SizedBox(
                                    width: (context.mounted)
                                        ? MediaQuery.of(context).size.width /
                                                2 -
                                            16
                                        : 350,
                                    height: (context.mounted)
                                        ? MediaQuery.of(context).size.width /
                                                2 -
                                            16
                                        : 350,
                                    child: await ImageSaver()
                                        .displayImageFromFile(
                                            dataItem.imageName),
                                  )
                                : SizedBox(
                                    height: (context.mounted)
                                        ? MediaQuery.of(context).size.width /
                                                4 -
                                            21
                                        : 350,
                                    width: (context.mounted)
                                        ? MediaQuery.of(context).size.width /
                                                4 -
                                            21
                                        : 350,
                                    child: await ImageSaver()
                                        .displayImageFromFile(
                                            dataItem.imageName),
                                  )),
                      ],
                    ),
                    if (isAndroid)
                      Positioned(
                        bottom: 8.0,
                        right: 8.0,
                        child: SeasonSelector.getSeasonBadge(dataItem.season),
                      ),
                  ] else if (size[0] >= 2) ...[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: isAndroid
                                    ? SizedBox(
                                        height: (context.mounted)
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4 -
                                                12
                                            : 350,
                                        width: (context.mounted)
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4 -
                                                12
                                            : 350,
                                        child: await ImageSaver()
                                            .displayImageFromFile(
                                                dataItem.imageName),
                                      )
                                    : SizedBox(
                                        height: (context.mounted)
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4 -
                                                21
                                            : 350,
                                        width: (context.mounted)
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4 -
                                                21
                                            : 350,
                                        child: await ImageSaver()
                                            .displayImageFromFile(
                                                dataItem.imageName),
                                      )),
                            const SizedBox(width: 8.0),
                            Column(
                              children: [
                                Text(dataItem.name),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ] else ...[
                    Column(
                      children: <Widget>[
                        Row(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: isAndroid
                                    ? SizedBox(
                                        height: (context.mounted)
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4 -
                                                12
                                            : 350,
                                        width: (context.mounted)
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4 -
                                                12
                                            : 350,
                                        child: await ImageSaver()
                                            .displayImageFromFile(
                                                dataItem.imageName),
                                      )
                                    : SizedBox(
                                        height: (context.mounted)
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4 -
                                                21
                                            : 350,
                                        width: (context.mounted)
                                            ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4 -
                                                21
                                            : 350,
                                        child: await ImageSaver()
                                            .displayImageFromFile(
                                                dataItem.imageName),
                                      )),
                          ],
                        ),
                      ],
                    ),
                  ],
                  if (isWebMobile)
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: SeasonSelector.getSeasonBadge(dataItem.season),
                    ),
                ],
              ),
            ),
          ),
        );

        list.add(widget);
      }
      if (breakNow) break;
    }
    setState(() {});
    return list;
  }
}

List<List<Object>> sizes = [
  [
    [2, 2],
    [2, 1],
    [1, 1],
    [1, 1]
  ],
  [4, 2],
  [
    [2, 1],
    [1, 1],
    [1, 1],
    [2, 2]
  ]
];

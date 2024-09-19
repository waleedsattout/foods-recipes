import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:foods/constants.dart';
import 'package:foods/screens/add_category_screen.dart';
import 'package:foods/screens/add_ingredient_screen.dart';
import 'package:foods/screens/add_recipe_screen.dart';
import 'package:foods/screens/advanced_search_screen.dart';
import 'package:foods/screens/categoris_list_screen.dart';
import 'package:foods/screens/home_screen.dart';
import 'package:foods/screens/impor_export_screen.dart';
import 'package:foods/screens/ingredients_list_screen.dart';
import 'package:foods/screens/manage_measurements_units_screen.dart';

class FoodDrawer extends StatelessWidget {
  final int screenIndex;

  const FoodDrawer({super.key, required this.screenIndex});

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context);
    List<Screens> dests = sharedPreferences!.getString("locale") == "ar"
        ? destinationsArabic
        : destinations;
    return NavigationDrawer(
      selectedIndex: screenIndex,
      onDestinationSelected: (int selectedScreen) {
        if (screenIndex == selectedScreen) return;
        if (selectedScreen == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (selectedScreen == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AdvancedSearchScreen()),
          );
        } else if (selectedScreen == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
          );
        } else if (selectedScreen == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AddIngredientScreen()),
          );
        } else if (selectedScreen == 4) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const IngredientsListScreen()),
          );
        } else if (selectedScreen == 5) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AddCategoryScreen()),
          );
        } else if (selectedScreen == 6) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const CategoriesListScreen()),
          );
        } else if (selectedScreen == 7) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const ManageMeasurementUnits()),
          );
        } else if (selectedScreen == 8) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ImportExportScreen()),
          );
        }
      },
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text(
            localization!.general,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        NavigationDrawerDestination(
          label: Text(dests[0].text),
          icon: dests[0].icon,
          selectedIcon: dests[0].selectedIcon,
        ),
        NavigationDrawerDestination(
          label: Text(dests[1].text),
          icon: dests[1].icon,
          selectedIcon: dests[1].selectedIcon,
        ),
        NavigationDrawerDestination(
          label: Text(dests[2].text),
          icon: dests[2].icon,
          selectedIcon: dests[2].selectedIcon,
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text(
            localization.ingredients,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        NavigationDrawerDestination(
          label: Text(dests[3].text),
          icon: dests[3].icon,
          selectedIcon: dests[3].selectedIcon,
        ),
        NavigationDrawerDestination(
          label: Text(dests[4].text),
          icon: dests[4].icon,
          selectedIcon: dests[4].selectedIcon,
        ),
        NavigationDrawerDestination(
          label: Text(dests[5].text),
          icon: dests[5].icon,
          selectedIcon: dests[5].selectedIcon,
        ),
        NavigationDrawerDestination(
          label: Text(dests[6].text),
          icon: dests[6].icon,
          selectedIcon: dests[6].selectedIcon,
        ),
        NavigationDrawerDestination(
          label: Text(dests[7].text),
          icon: dests[7].icon,
          selectedIcon: dests[7].selectedIcon,
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text(
            localization.more,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ExpandableDrawerItem(
          label: Text(
            localization.advacedOptions,
            style: Theme.of(context).textTheme.labelLarge!,
          ),
          isExpanded: screenIndex == 8,
          icon: const Icon(Icons.settings),
          children: [
            NavigationDrawerDestination(
                label: Text(localization.advacedOptions),
                icon: const Icon(Icons.import_export_rounded))
          ],
        )
      ],
    );
  }
}

//todo: we need to reconsider isExpanded
class ExpandableDrawerItem extends NavigationDrawerDestination {
  final List<Widget> children;
  final bool isExpanded;

  const ExpandableDrawerItem(
      {super.key,
      required super.icon,
      required super.label,
      required this.children,
      this.isExpanded = false});

  @override
  Widget build(BuildContext context) {
    return ExpandableList(
        title: label, icon: icon, isExpanded: isExpanded, children: children);
  }
}

class ExpandableList extends StatefulWidget {
  final Widget title;
  final Widget icon;
  final List<Widget> children;
  final bool isExpanded;

  const ExpandableList({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.isExpanded = false,
  });

  @override
  State<StatefulWidget> createState() => _ExpandableListState();
}

class _ExpandableListState extends State<ExpandableList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heightAnimation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (_isExpanded) _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  if (_isExpanded) {
                    _controller.forward();
                  } else {
                    _controller.reverse();
                  }
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  color: _isExpanded
                      ? Theme.of(context).colorScheme.surfaceContainerHigh
                      : null,
                  child: ListTile(
                    title: widget.title,
                    leading: widget.icon,
                    trailing: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                  ),
                ),
              ),
            ),
            SizeTransition(
              sizeFactor: _heightAnimation,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  children: widget.children,
                ),
              ),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

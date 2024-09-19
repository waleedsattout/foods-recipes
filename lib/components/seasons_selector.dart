import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:foods/constants.dart';
import 'package:foods/models/season_info.dart';
import 'package:foods/providers/shared_data_provider.dart';
import 'package:foods/utils/my_flutter_app_icons.dart';

// ignore: must_be_immutable
class SeasonSelector extends StatelessWidget {
  final String selectedSeason = '';
  AppLocalizations? localization;
  SeasonSelector({super.key});

  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context);

    return DropdownButtonFormField<String>(
      value: selectedSeason,
      items: seasons
          .map((season) => DropdownMenuItem(
                value: season.name,
                child: Text(season.name),
              ))
          .toList(),
      hint: Text(localization!.selectSeason),
      onChanged: (String? value) {},
    );
  }

  static Widget getSeasonSelectionMenu(
      {String name = "",
      double width = 250,
      SharedDataProvider? provider,
      Function? callback}) {
    provider ??= sharedDataProvider;
    // ignore: no_leading_underscores_for_local_identifiers
    List<SeasonInfo> _seasons = sharedPreferences!.getString("locale") == 'ar'
        ? seasonsArabic
        : seasons;
    return DropdownMenu<SeasonInfo>(
      width: width,
      requestFocusOnTap: true,
      label: Text(
          sharedPreferences!.getString("locale") == 'ar' ? 'الفصل' : "season"),
      initialSelection: name != ""
          ? _seasons.where((e) => e.name == name).first
          : provider.season,
      onSelected: (s) {
        provider!.season = s!;
        if (callback != null) callback(s);
      },
      dropdownMenuEntries:
          _seasons.map<DropdownMenuEntry<SeasonInfo>>((season) {
        return DropdownMenuEntry<SeasonInfo>(
          value: season,
          label: season.name,
          leadingIcon: Icon(season.icon),
        );
      }).toList(),
    );
  }

  static Widget getSeasonBadge(String name) {
    var seasonData = seasons.where((e) => e.name == name);
    SeasonInfo? season;
    if (seasonData.isNotEmpty) {
      season = seasonData.first;
    } else {
      seasonData = seasonsArabic.where((e) => e.name == name);
      if (seasonData.isNotEmpty) {
        season = seasonData.first;
      }
    }
    season ??= seasons[0];
    return Chip(
      label: Text(season.name),
      avatar: Icon(season.icon, color: season.textColor),
      backgroundColor: season.backgroundColor,
      side: BorderSide.none,
      labelStyle: TextStyle(color: season.textColor),
    );
  }
}

List<SeasonInfo> seasons = [
  SeasonInfo(
      name: 'All year',
      icon: Icons.calendar_month,
      backgroundColor: colorScheme.primaryContainer,
      textColor: colorScheme.onPrimaryContainer),
  SeasonInfo(
      name: 'Spring',
      icon: Icons.local_florist,
      backgroundColor: const Color.fromARGB(255, 192, 239, 176),
      textColor: const Color.fromARGB(255, 51, 51, 51)),
  SeasonInfo(
    name: 'Summer',
    icon: Icons.wb_sunny,
    backgroundColor: const Color.fromARGB(255, 255, 249, 196),
    textColor: const Color.fromARGB(255, 51, 51, 51),
  ),
  SeasonInfo(
    name: 'Autumn',
    icon: MyFlutterApp.autumn,
    backgroundColor: const Color.fromARGB(255, 255, 219, 209),
    textColor: const Color.fromARGB(255, 51, 51, 51),
  ),
  SeasonInfo(
    name: 'Winter',
    icon: Icons.ac_unit,
    backgroundColor: const Color.fromARGB(255, 224, 224, 255),
    textColor: const Color.fromARGB(255, 51, 51, 51),
  ),
];
List<SeasonInfo> seasonsArabic = [
  SeasonInfo(
      name: 'كل السنة',
      icon: Icons.calendar_month,
      backgroundColor: colorScheme.primaryContainer,
      textColor: colorScheme.onPrimaryContainer),
  SeasonInfo(
      name: 'الربيع',
      icon: Icons.local_florist,
      backgroundColor: const Color.fromARGB(255, 192, 239, 176),
      textColor: const Color.fromARGB(255, 51, 51, 51)),
  SeasonInfo(
    name: 'الصيف',
    icon: Icons.wb_sunny,
    backgroundColor: const Color.fromARGB(255, 255, 249, 196),
    textColor: const Color.fromARGB(255, 51, 51, 51),
  ),
  SeasonInfo(
    name: 'الخريف',
    icon: MyFlutterApp.autumn,
    backgroundColor: const Color.fromARGB(255, 255, 219, 209),
    textColor: const Color.fromARGB(255, 51, 51, 51),
  ),
  SeasonInfo(
    name: 'الشتاء',
    icon: Icons.ac_unit,
    backgroundColor: const Color.fromARGB(255, 224, 224, 255),
    textColor: const Color.fromARGB(255, 51, 51, 51),
  ),
];

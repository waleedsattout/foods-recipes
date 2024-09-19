import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'season_info.g.dart';

@HiveType(typeId: 4)
class SeasonInfo extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final IconData icon;

  @HiveField(2)
  final Color backgroundColor;

  @HiveField(3)
  final Color textColor;

  SeasonInfo({
    required this.name,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });
}

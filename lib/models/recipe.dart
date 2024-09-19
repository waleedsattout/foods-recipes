import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String description;

  @HiveField(2)
  String season;

  @HiveField(3)
  List<String> steps; 

  @HiveField(4)
  String imageName;

  @HiveField(5)
  double rating;

  Recipe({
    required this.name,
    required this.description,
    required this.season,
    required this.steps,
    required this.imageName,
    required this.rating,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        name: json['name'] as String,
        description: json['description'] as String,
        season: json['season'] as String,
        steps: json['steps'].cast<String>(), // Directly cast to List<String>
        imageName: json['imageName'] as String,
        rating: json['rating'] as double,
      );

  Map<String, dynamic> toJson() {
    // Accessing fields using getters is recommended by Hive
    return {
      'name': name,
      'description': description,
      'season': season,
      'steps': StepsAdapter.toJson(steps), // Use custom adapter
      'imageName': imageName,
      'rating': rating,
    };
  }
}

class StepsAdapter extends HiveObject {
  final List<String> steps;

  StepsAdapter({required this.steps});

  static StepsAdapter fromJson(List<dynamic> json) => StepsAdapter(
        steps: json.cast<String>(), // Convert to List<String>
      );

  static List<dynamic> toJson(List<String> steps) => steps.toList();
}

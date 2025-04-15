class SpaceCategory {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SpaceSubcategory> subcategories;

  SpaceCategory({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.subcategories,
  });

  factory SpaceCategory.fromJson(Map<String, dynamic> json) {
    return SpaceCategory(
      id: json['category_id'].toString(),
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      subcategories: (json['subcategories'] as List<dynamic>? ?? [])
          .map((item) => SpaceSubcategory.fromJson(item))
          .toList(),
    );
  }
}

class SpaceSubcategory {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  SpaceSubcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SpaceSubcategory.fromJson(Map<String, dynamic> json) {
    return SpaceSubcategory(
      id: json['subcategory_id'].toString(),
      categoryId: json['category_id'].toString(),
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
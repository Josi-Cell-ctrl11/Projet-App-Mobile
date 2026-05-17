/// Plat affiché dans le menu d’un restaurant.
class MenuItemModel {
  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceFcfa,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final double priceFcfa;
  final String imageUrl;

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
        id: json["id"] as String,
        name: json["name"] as String,
        description: json["description"] as String? ?? "",
        priceFcfa: (json["priceFcfa"] as num).toDouble(),
        imageUrl: json["imageUrl"] as String? ?? "",
      );
}

/// Restaurant OzelFoods.
class RestaurantModel {
  const RestaurantModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.deliveryMinutes,
    required this.imageUrl,
    required this.menu,
  });

  final String id;
  final String name;
  final String category;
  final double rating;
  final int deliveryMinutes;
  final String imageUrl;
  final List<MenuItemModel> menu;

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    final rawMenu = json["menu"] as List<dynamic>? ?? [];
    return RestaurantModel(
      id: json["id"] as String,
      name: json["name"] as String,
      category: json["category"] as String? ?? "local",
      rating: (json["rating"] as num?)?.toDouble() ?? 0,
      deliveryMinutes: (json["deliveryMinutes"] as num?)?.toInt() ?? 30,
      imageUrl: json["imageUrl"] as String? ?? "",
      menu: rawMenu
          .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

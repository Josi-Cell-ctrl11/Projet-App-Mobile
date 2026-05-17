/// Plat affiché dans le menu d'un restaurant.
class MenuItemModel {
  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceFcfa,
    required this.imageUrl,
    this.isMenuDuJour = false,
  });

  final String id;
  final String name;
  final String description;
  final double priceFcfa;
  final String imageUrl;

  /// Vrai si ce plat fait partie du menu du jour (max 3 par restaurant).
  final bool isMenuDuJour;

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
        id: json["id"] as String,
        name: json["name"] as String,
        description: json["description"] as String? ?? "",
        priceFcfa: (json["priceFcfa"] as num).toDouble(),
        imageUrl: json["imageUrl"] as String? ?? "",
        isMenuDuJour: json["isMenuDuJour"] as bool? ?? false,
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
    this.specialite = "",
    this.isOpen = true,
  });

  final String id;
  final String name;

  /// Categorie generale (local, pizza, healthy...).
  final String category;

  /// Specialite culinaire principale du restaurant (ex: "Porc braise", "Moyo").
  final String specialite;

  final double rating;
  final int deliveryMinutes;
  final String imageUrl;
  final bool isOpen;

  /// Tous les plats — filtrer par [isMenuDuJour] pour le menu du jour (max 3).
  final List<MenuItemModel> menu;

  /// Plats du menu du jour uniquement (max 3 selon regle metier).
  List<MenuItemModel> get menuDuJour =>
      menu.where((m) => m.isMenuDuJour).take(3).toList();

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    final rawMenu = json["menu"] as List<dynamic>? ?? [];
    return RestaurantModel(
      id: json["id"] as String,
      name: json["name"] as String,
      category: json["category"] as String? ?? "local",
      specialite: json["specialite"] as String? ?? "",
      rating: (json["rating"] as num?)?.toDouble() ?? 0,
      deliveryMinutes: (json["deliveryMinutes"] as num?)?.toInt() ?? 30,
      imageUrl: json["imageUrl"] as String? ?? "",
      isOpen: json["isOpen"] as bool? ?? true,
      menu: rawMenu
          .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

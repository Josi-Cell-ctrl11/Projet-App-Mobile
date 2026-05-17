import "dart:convert";

import "package:flutter/services.dart";

import "../../shared/models/restaurant_model.dart";

/// Chargement des restaurants depuis l’asset JSON (mock API).
class RestaurantRepository {
  RestaurantRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<List<RestaurantModel>> loadRestaurants() async {
    final raw = await _bundle.loadString("assets/mock/restaurants.json");
    final map = json.decode(raw) as Map<String, dynamic>;
    final list = map["restaurants"] as List<dynamic>? ?? [];
    return list
        .map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

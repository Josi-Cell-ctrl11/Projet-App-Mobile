import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../data/repositories/restaurant_repository.dart";
import "../../../shared/models/restaurant_model.dart";

final restaurantRepositoryProvider = Provider<RestaurantRepository>(
  (ref) => RestaurantRepository(),
);

/// Liste des restaurants (mock JSON asset).
final restaurantsProvider = FutureProvider<List<RestaurantModel>>((ref) async {
  final repo = ref.watch(restaurantRepositoryProvider);
  return repo.loadRestaurants();
});

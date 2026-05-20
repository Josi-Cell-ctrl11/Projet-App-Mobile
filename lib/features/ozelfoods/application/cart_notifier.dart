import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../shared/models/cart_line.dart";
import "../../../shared/models/restaurant_model.dart";

/// Panier OzelFoods (un seul restaurant à la fois pour le MVP).
class CartNotifier extends Notifier<List<CartLine>> {
  @override
  List<CartLine> build() => [];

  void clear() => state = [];

  void addItem({
    required MenuItemModel item,
    required RestaurantModel restaurant,
  }) {
    final existing = state.where((l) => l.item.id == item.id).toList();
    if (state.isNotEmpty && state.first.restaurantId != restaurant.id) {
      // Règle MVP : changement de restaurant = nouveau panier.
      state = [
        CartLine(
          item: item,
          quantity: 1,
          restaurantId: restaurant.id,
          restaurantName: restaurant.name,
        ),
      ];
      return;
    }
    if (existing.isEmpty) {
      state = [
        ...state,
        CartLine(
          item: item,
          quantity: 1,
          restaurantId: restaurant.id,
          restaurantName: restaurant.name,
        ),
      ];
    } else {
      state = [
        for (final line in state)
          if (line.item.id == item.id)
            line.copyWith(quantity: line.quantity + 1)
          else
            line,
      ];
    }
  }

  void decrementLine(String menuItemId) {
    final next = <CartLine>[];
    for (final line in state) {
      if (line.item.id != menuItemId) {
        next.add(line);
        continue;
      }
      if (line.quantity > 1) {
        next.add(line.copyWith(quantity: line.quantity - 1));
      }
    }
    state = next;
  }

  /// Incremente la quantite d'un plat dans le panier.
  void incrementLine(String menuItemId) {
    state = [
      for (final line in state)
        if (line.item.id == menuItemId)
          line.copyWith(quantity: line.quantity + 1)
        else
          line,
    ];
  }

  double get subtotal =>
      state.fold<double>(0, (sum, line) => sum + line.lineTotal);
}

final cartProvider = NotifierProvider<CartNotifier, List<CartLine>>(
  CartNotifier.new,
);

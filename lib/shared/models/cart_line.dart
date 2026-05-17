import "restaurant_model.dart";

/// Ligne du panier OzelFoods.
class CartLine {
  const CartLine({
    required this.item,
    required this.quantity,
    required this.restaurantId,
    required this.restaurantName,
  });

  final MenuItemModel item;
  final int quantity;
  final String restaurantId;
  final String restaurantName;

  double get lineTotal => item.priceFcfa * quantity;

  CartLine copyWith({int? quantity}) => CartLine(
        item: item,
        quantity: quantity ?? this.quantity,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
      );
}

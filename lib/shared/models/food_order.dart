import "food_order_status.dart";

/// Commande OzelFoods (mock).
class FoodOrder {
  const FoodOrder({
    required this.id,
    required this.restaurantName,
    required this.totalFcfa,
    required this.status,
    required this.createdAt,
    this.restaurantAccepted = true,
    this.lateMinutes = 0,
    this.cancelled = false,
  });

  final String id;
  final String restaurantName;
  final double totalFcfa;
  final FoodOrderStatus status;
  final DateTime createdAt;

  /// Simule l’acceptation restaurant dans les 3 minutes.
  final bool restaurantAccepted;

  /// Minutes de retard livreur (pour afficher remboursement points 10 %).
  final int lateMinutes;

  /// Annulation auto si le restaurant n’accepte pas (mock).
  final bool cancelled;

  FoodOrder copyWith({
    FoodOrderStatus? status,
    bool? restaurantAccepted,
    int? lateMinutes,
    bool? cancelled,
  }) =>
      FoodOrder(
        id: id,
        restaurantName: restaurantName,
        totalFcfa: totalFcfa,
        status: status ?? this.status,
        createdAt: createdAt,
        restaurantAccepted: restaurantAccepted ?? this.restaurantAccepted,
        lateMinutes: lateMinutes ?? this.lateMinutes,
        cancelled: cancelled ?? this.cancelled,
      );
}

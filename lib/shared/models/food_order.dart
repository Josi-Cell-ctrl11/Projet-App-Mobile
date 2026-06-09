import "package:cloud_firestore/cloud_firestore.dart";

import "food_order_status.dart";

/// Commande OzelFoods.
class FoodOrder {
  const FoodOrder({
    required this.id,
    required this.restaurantName,
    required this.totalFcfa,
    required this.status,
    required this.createdAt,
    this.userId = "",
    this.restaurantAccepted = true,
    this.lateMinutes = 0,
    this.cancelled = false,
  });

  final String id;
  final String userId;
  final String restaurantName;
  final double totalFcfa;
  final FoodOrderStatus status;
  final DateTime createdAt;
  final bool restaurantAccepted;
  final int lateMinutes;
  final bool cancelled;

  FoodOrder copyWith({
    FoodOrderStatus? status,
    bool? restaurantAccepted,
    int? lateMinutes,
    bool? cancelled,
  }) =>
      FoodOrder(
        id: id,
        userId: userId,
        restaurantName: restaurantName,
        totalFcfa: totalFcfa,
        status: status ?? this.status,
        createdAt: createdAt,
        restaurantAccepted: restaurantAccepted ?? this.restaurantAccepted,
        lateMinutes: lateMinutes ?? this.lateMinutes,
        cancelled: cancelled ?? this.cancelled,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "restaurantName": restaurantName,
        "totalFcfa": totalFcfa,
        "status": status.name,
        "createdAt": Timestamp.fromDate(createdAt),
        "restaurantAccepted": restaurantAccepted,
        "lateMinutes": lateMinutes,
        "cancelled": cancelled,
      };

  factory FoodOrder.fromJson(Map<String, dynamic> json) => FoodOrder(
        id: json["id"] as String? ?? "",
        userId: json["userId"] as String? ?? "",
        restaurantName: json["restaurantName"] as String? ?? "",
        totalFcfa: (json["totalFcfa"] as num?)?.toDouble() ?? 0,
        status: FoodOrderStatus.values.byName(
          json["status"] as String? ?? "preparing",
        ),
        createdAt: json["createdAt"] is Timestamp
            ? (json["createdAt"] as Timestamp).toDate()
            : DateTime.now(),
        restaurantAccepted: json["restaurantAccepted"] as bool? ?? true,
        lateMinutes: json["lateMinutes"] as int? ?? 0,
        cancelled: json["cancelled"] as bool? ?? false,
      );
}

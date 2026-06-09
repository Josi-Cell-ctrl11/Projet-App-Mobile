import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/services/firestore_service.dart";
import "../../../shared/models/food_order.dart";
import "../../../shared/models/food_order_status.dart";
import "../../auth/application/auth_session.dart";

/// Provider du stream Firestore des commandes food de l'utilisateur connecté.
final foodOrdersStreamProvider =
    StreamProvider<List<FoodOrder>>((ref) {
  final uid = ref.watch(authSessionProvider).user?.id;
  if (uid == null) return const Stream.empty();

  return FirestoreService.instance
      .commandesFoodsStream(uid)
      .map((snap) => snap.docs
          .map((d) => FoodOrder.fromJson({...d.data(), "id": d.id}))
          .toList());
});

/// Provider d'une commande précise en temps réel.
final foodOrderLiveProvider =
    StreamProvider.family<FoodOrder?, String>((ref, orderId) {
  return FirebaseFirestore.instance
      .collection("commandes_foods")
      .doc(orderId)
      .snapshots()
      .map((snap) {
    if (!snap.exists || snap.data() == null) return null;
    return FoodOrder.fromJson({...snap.data()!, "id": snap.id});
  });
});

/// Notifier pour créer des commandes et les écrire dans Firestore.
class FoodOrdersNotifier extends Notifier<List<FoodOrder>> {
  @override
  List<FoodOrder> build() => [];

  /// Crée une commande, l'écrit dans Firestore et retourne l'objet.
  Future<FoodOrder> startOrder({
    required String restaurantName,
    required double totalFcfa,
    required String userId,
    bool restaurantAccepted = true,
    int lateMinutes = 0,
  }) async {
    final docRef = FirebaseFirestore.instance.collection("commandes_foods").doc();

    final order = FoodOrder(
      id: docRef.id,
      restaurantName: restaurantName,
      totalFcfa: totalFcfa,
      status: FoodOrderStatus.preparing,
      createdAt: DateTime.now(),
      userId: userId,
      restaurantAccepted: restaurantAccepted,
      lateMinutes: lateMinutes,
    );

    // Écrire dans Firestore
    await docRef.set(order.toJson());

    // Mettre à jour l'état local
    state = [order, ...state];

    return order;
  }

  int lateRefundPointsFor(FoodOrder order) {
    if (order.lateMinutes <= 15) return 0;
    return (order.totalFcfa * 0.10).round();
  }
}

final foodOrdersProvider =
    NotifierProvider<FoodOrdersNotifier, List<FoodOrder>>(
  FoodOrdersNotifier.new,
);

final latestFoodOrderProvider = Provider<FoodOrder?>((ref) {
  final list = ref.watch(foodOrdersProvider);
  return list.isEmpty ? null : list.first;
});

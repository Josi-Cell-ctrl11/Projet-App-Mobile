import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/constants/app_constants.dart";
import "../../../core/utils/food_business_rules.dart";
import "../../../shared/models/food_order.dart";
import "../../../shared/models/food_order_status.dart";

/// Commandes food actives + historique simple (mock).
class FoodOrdersNotifier extends Notifier<List<FoodOrder>> {
  final Map<String, Timer> _timers = {};

  @override
  List<FoodOrder> build() {
    ref.onDispose(() {
      for (final t in _timers.values) {
        t.cancel();
      }
      _timers.clear();
    });
    return [];
  }

  /// Crée une commande et simule la progression des statuts.
  FoodOrder startOrder({
    required String restaurantName,
    required double totalFcfa,
    bool restaurantAccepted = true,
    int lateMinutes = 0,
  }) {
    final id = "FO-${DateTime.now().millisecondsSinceEpoch}";
    final order = FoodOrder(
      id: id,
      restaurantName: restaurantName,
      totalFcfa: totalFcfa,
      status: FoodOrderStatus.preparing,
      createdAt: DateTime.now(),
      restaurantAccepted: restaurantAccepted,
      lateMinutes: lateMinutes,
    );
    state = [order, ...state];
    if (!restaurantAccepted) {
      _scheduleAutoCancel(id);
    } else {
      _simulateProgress(id);
    }
    return order;
  }

  /// Annulation automatique si le restaurant n’accepte pas sous 3 minutes (mock).
  void _scheduleAutoCancel(String id) {
    _timers[id]?.cancel();
    _timers[id] = Timer(
      Duration(minutes: AppConstants.restaurantAcceptanceMinutes),
      () {
        state = [
          for (final o in state)
            if (o.id == id) o.copyWith(cancelled: true) else o,
        ];
        _timers.remove(id);
      },
    );
  }

  void _simulateProgress(String id) {
    _timers[id]?.cancel();
    var step = 0;
    _timers[id] = Timer.periodic(const Duration(seconds: 4), (timer) {
      step++;
      state = [
        for (final o in state)
          if (o.id == id) _advance(o, step) else o,
      ];
      if (step >= 3) {
        timer.cancel();
        _timers.remove(id);
      }
    });
  }

  FoodOrder _advance(FoodOrder o, int step) {
    if (step == 1) {
      return o.copyWith(status: FoodOrderStatus.riderAssigned);
    }
    if (step == 2) {
      return o.copyWith(status: FoodOrderStatus.onTheWay);
    }
    return o.copyWith(status: FoodOrderStatus.delivered);
  }

  int lateRefundPointsFor(FoodOrder order) {
    if (order.lateMinutes <= AppConstants.lateDeliveryMinutes) return 0;
    return FoodBusinessRules.lateRefundPoints(
      order.totalFcfa,
      AppConstants.lateDeliveryRefundPercent,
    );
  }
}

final foodOrdersProvider = NotifierProvider<FoodOrdersNotifier, List<FoodOrder>>(
  FoodOrdersNotifier.new,
);

final latestFoodOrderProvider = Provider<FoodOrder?>((ref) {
  final list = ref.watch(foodOrdersProvider);
  return list.isEmpty ? null : list.first;
});

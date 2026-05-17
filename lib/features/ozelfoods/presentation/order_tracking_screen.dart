import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/constants/app_constants.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/models/food_order.dart";
import "../../../shared/models/food_order_status.dart";
import "../application/food_orders_notifier.dart";

/// Suivi de commande temps réel (statuts mock).
class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(foodOrdersProvider);
    final match = orders.where((o) => o.id == orderId);
    final order = match.isEmpty ? null : match.first;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Suivi")),
        body: const Center(child: Text("Commande introuvable.")),
      );
    }
    final notifier = ref.read(foodOrdersProvider.notifier);
    final refundPts = notifier.lateRefundPointsFor(order);
    final steps = FoodOrderStatus.values;
    final idx = steps.indexOf(order.status);

    return Scaffold(
      appBar: AppBar(title: const Text("Suivi commande")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            order.restaurantName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text("Commande ${order.id}"),
          const SizedBox(height: 8),
          Text(
            "Total : ${Formatters.fcfa(order.totalFcfa)}",
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (order.cancelled) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
              ),
              child: Text(
                "Annulation automatique : le restaurant n’a pas accepté sous "
                "${AppConstants.restaurantAcceptanceMinutes} minute(s).",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (!order.cancelled && order.lateMinutes > AppConstants.lateDeliveryMinutes) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "Retard livreur détecté (> ${AppConstants.lateDeliveryMinutes} min). "
                "Remboursement simulé : $refundPts points Ozel "
                "(${AppConstants.lateDeliveryRefundPercent * 100}% du total).",
                style: const TextStyle(height: 1.35),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (!order.cancelled)
            Stepper(
              currentStep: idx.clamp(0, steps.length - 1),
              controlsBuilder: (context, details) => const SizedBox.shrink(),
              steps: [
                for (var i = 0; i < steps.length; i++)
                  Step(
                    title: Text(steps[i].labelFr),
                    isActive: i <= idx,
                    state: i < idx
                        ? StepState.complete
                        : (i == idx ? StepState.editing : StepState.indexed),
                    content: const SizedBox.shrink(),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          const Text(
            "Les transitions de statut sont simulées côté app (Timer) pour le MVP.",
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

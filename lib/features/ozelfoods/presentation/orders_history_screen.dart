import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/models/food_order.dart";
import "../../../shared/models/food_order_status.dart";
import "../application/food_orders_notifier.dart";

/// Historique des commandes OzelFoods depuis Firestore.
class OrdersHistoryScreen extends ConsumerWidget {
  const OrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(foodOrdersStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.black,
        title: const Text(
          "Mes commandes",
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.black),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            "Erreur : $e",
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) return const _EmptyHistory();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) =>
                _OrderHistoryCard(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  const _OrderHistoryCard({required this.order});
  final FoodOrder order;

  @override
  Widget build(BuildContext context) {
    final color = order.cancelled
        ? Colors.red
        : order.status == FoodOrderStatus.delivered
            ? AppColors.success
            : AppColors.primary;

    return GestureDetector(
      onTap: () => context.push("/ozelfoods/suivi/${order.id}"),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.restaurant_rounded, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.restaurantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${order.createdAt.day.toString().padLeft(2, '0')}/"
                    "${order.createdAt.month.toString().padLeft(2, '0')}/"
                    "${order.createdAt.year}",
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.fcfa(order.totalFcfa),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                _StatusChip(
                    status: order.status, cancelled: order.cancelled),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.cancelled});
  final FoodOrderStatus status;
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    if (cancelled) return _chip("Annulée", Colors.red);
    switch (status) {
      case FoodOrderStatus.delivered:
        return _chip("Livrée", AppColors.success);
      case FoodOrderStatus.onTheWay:
        return _chip("En route", AppColors.primary);
      case FoodOrderStatus.riderAssigned:
        return _chip("Livreur assigné", Colors.blue);
      case FoodOrderStatus.preparing:
        return _chip("En préparation", AppColors.warning);
    }
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 72,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            "Aucune commande pour l'instant",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Commandez votre premier repas OzelFoods",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go("/ozelfoods"),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.restaurant_rounded),
            label: const Text("Voir les restaurants"),
          ),
        ],
      ),
    );
  }
}

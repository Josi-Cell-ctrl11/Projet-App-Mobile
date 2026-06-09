import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/models/food_order.dart";
import "../../../shared/models/food_order_status.dart";
import "../application/food_orders_notifier.dart";

/// Suivi de commande OzelFoods en temps réel via Firestore Stream.
class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(foodOrderLiveProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.black,
        title: const Text(
          "Suivi de commande",
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(foodOrderLiveProvider(orderId)),
          ),
        ],
      ),
      body: orderAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text("Chargement du suivi...",
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text("Erreur : $e",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
        data: (order) {
          if (order == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  const Text("Commande introuvable"),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go("/ozelfoods"),
                    child: const Text("Retour aux restaurants"),
                  ),
                ],
              ),
            );
          }
          return _OrderTrackingBody(order: order);
        },
      ),
    );
  }
}

class _OrderTrackingBody extends StatelessWidget {
  const _OrderTrackingBody({required this.order});
  final FoodOrder order;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête commande ──────────────────────────────────────────────
          _OrderHeader(order: order),
          const SizedBox(height: 20),

          // ── Bannière annulation ───────────────────────────────────────────
          if (order.cancelled) ...[
            _BannerAlert(
              color: Colors.red,
              icon: Icons.cancel_outlined,
              message:
                  "Commande annulée — le restaurant n'a pas répondu dans les délais.",
            ),
            const SizedBox(height: 16),
          ],

          // ── Étapes de progression ─────────────────────────────────────────
          if (!order.cancelled) ...[
            _ProgressionSteps(order: order),
            const SizedBox(height: 20),
          ],

          // ── Temps estimé ──────────────────────────────────────────────────
          if (!order.cancelled &&
              order.status != FoodOrderStatus.delivered) ...[
            _EstimationCard(order: order),
            const SizedBox(height: 20),
          ],

          // ── Livraison effectuée ────────────────────────────────────────────
          if (order.status == FoodOrderStatus.delivered) ...[
            _BannerAlert(
              color: AppColors.success,
              icon: Icons.check_circle_outline,
              message:
                  "🎉 Commande livrée ! Merci d'avoir utilisé OzelFoods.",
            ),
            const SizedBox(height: 16),
          ],

          // ── Récapitulatif ─────────────────────────────────────────────────
          _OrderSummaryCard(order: order),
          const SizedBox(height: 24),

          // ── Bouton retour ─────────────────────────────────────────────────
          if (order.cancelled || order.status == FoodOrderStatus.delivered)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () => context.go("/ozelfoods"),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.restaurant_rounded),
                label: const Text(
                  "Commander à nouveau",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── En-tête commande ──────────────────────────────────────────────────────────

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order});
  final FoodOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.restaurant_rounded,
                color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.restaurantName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Commande #${order.id.substring(0, 8).toUpperCase()}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(status: order.status, cancelled: order.cancelled),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.cancelled});
  final FoodOrderStatus status;
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    if (cancelled) {
      return _badge("Annulée", Colors.red);
    }
    switch (status) {
      case FoodOrderStatus.preparing:
        return _badge("En préparation", AppColors.warning);
      case FoodOrderStatus.riderAssigned:
        return _badge("Livreur assigné", Colors.blue);
      case FoodOrderStatus.onTheWay:
        return _badge("En route", AppColors.primary);
      case FoodOrderStatus.delivered:
        return _badge("Livrée ✓", AppColors.success);
    }
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      );
}

// ── Étapes de progression ─────────────────────────────────────────────────────

class _ProgressionSteps extends StatelessWidget {
  const _ProgressionSteps({required this.order});
  final FoodOrder order;

  @override
  Widget build(BuildContext context) {
    final steps = FoodOrderStatus.values;
    final current = order.cancelled ? -1 : steps.indexOf(order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final i = entry.key;
          final step = entry.value;
          final done = i < current;
          final active = i == current;
          final pending = i > current;

          return Column(
            children: [
              Row(
                children: [
                  // Icône
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: done || active
                          ? AppColors.primary
                          : AppColors.surface,
                      shape: BoxShape.circle,
                      border: active
                          ? Border.all(
                              color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Icon(
                      done
                          ? Icons.check_rounded
                          : _stepIcon(step),
                      color: done || active
                          ? Colors.white
                          : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.labelFr,
                          style: TextStyle(
                            fontWeight: active
                                ? FontWeight.w800
                                : FontWeight.w500,
                            fontSize: 14,
                            color: pending
                                ? AppColors.textSecondary
                                : AppColors.black,
                          ),
                        ),
                        if (active)
                          const Text(
                            "En cours...",
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (active)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  if (done)
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 18),
                ],
              ),
              if (i < steps.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Container(
                    width: 2,
                    height: 24,
                    color: i < current
                        ? AppColors.primary
                        : AppColors.surface,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  IconData _stepIcon(FoodOrderStatus s) {
    switch (s) {
      case FoodOrderStatus.preparing:
        return Icons.restaurant_menu_rounded;
      case FoodOrderStatus.riderAssigned:
        return Icons.person_rounded;
      case FoodOrderStatus.onTheWay:
        return Icons.delivery_dining_rounded;
      case FoodOrderStatus.delivered:
        return Icons.done_all_rounded;
    }
  }
}

// ── Estimation ────────────────────────────────────────────────────────────────

class _EstimationCard extends StatelessWidget {
  const _EstimationCard({required this.order});
  final FoodOrder order;

  String get _estimatedTime {
    final base = order.createdAt.add(const Duration(minutes: 30));
    final h = base.hour.toString().padLeft(2, "0");
    final m = base.minute.toString().padLeft(2, "0");
    return "$h:$m";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Heure de livraison estimée",
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                Text(
                  "Vers $_estimatedTime",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.live_tv_rounded,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 4),
          const Text(
            "Temps réel",
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Récapitulatif ─────────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});
  final FoodOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Récapitulatif",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: "Restaurant",
            value: order.restaurantName,
          ),
          _SummaryRow(
            label: "Montant payé",
            value: Formatters.fcfa(order.totalFcfa),
            valueColor: AppColors.primary,
            bold: true,
          ),
          _SummaryRow(
            label: "Date",
            value:
                "${order.createdAt.day.toString().padLeft(2, '0')}/"
                "${order.createdAt.month.toString().padLeft(2, '0')}/"
                "${order.createdAt.year} "
                "${order.createdAt.hour.toString().padLeft(2, '0')}:"
                "${order.createdAt.minute.toString().padLeft(2, '0')}",
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bannière alerte ────────────────────────────────────────────────────────────

class _BannerAlert extends StatelessWidget {
  const _BannerAlert({
    required this.color,
    required this.icon,
    required this.message,
  });
  final Color color;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

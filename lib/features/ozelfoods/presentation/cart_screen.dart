import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/constants/app_constants.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/utils/food_business_rules.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../../shared/widgets/price_tag.dart";
import "../application/cart_notifier.dart";

/// Panier : récap, frais de livraison mock, total.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  static const double deliveryFeeFcfa = 500;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartProvider);
    final subtotal = ref.read(cartProvider.notifier).subtotal;
    final total = subtotal + deliveryFeeFcfa;
    final meets = FoodBusinessRules.meetsMinimumOrder(
      subtotal,
      AppConstants.minFoodOrderFcfa,
    );
    return Scaffold(
      appBar: AppBar(title: const Text("Panier")),
      body: lines.isEmpty
          ? const Center(child: Text("Votre panier est vide."))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: lines.length,
                    separatorBuilder: (_, __) => const Divider(height: 20),
                    itemBuilder: (context, i) {
                      final line = lines[i];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  line.restaurantName,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              PriceTag(line.lineTotal),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => ref
                                        .read(cartProvider.notifier)
                                        .decrementLine(line.item.id),
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text("${line.quantity}"),
                                  IconButton(
                                    onPressed: () => ref
                                        .read(cartProvider.notifier)
                                        .incrementLine(line.item.id),
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        offset: Offset(0, -4),
                        color: Color(0x14000000),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Sous-total"),
                            PriceTag(subtotal),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Livraison (mock)"),
                            PriceTag(deliveryFeeFcfa),
                          ],
                        ),
                        const Divider(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total",
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            PriceTag(
                              total,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        if (!meets) ...[
                          const SizedBox(height: 10),
                          Text(
                            "Commande minimum : "
                            "${Formatters.fcfa(AppConstants.minFoodOrderFcfa)} "
                            "(hors frais de livraison).",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        OzelPrimaryButton(
                          label: "Commander",
                          enabled: meets,
                          onPressed: () =>
                              context.push("/ozelfoods/checkout"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

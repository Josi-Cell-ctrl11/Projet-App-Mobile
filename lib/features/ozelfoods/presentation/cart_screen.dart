import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/constants/app_constants.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/utils/food_business_rules.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../../shared/widgets/price_tag.dart";
import "../../auth/application/auth_session.dart";
import "../application/cart_notifier.dart";

/// Panier : récap, frais de livraison mock, total.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  static const double deliveryFeeFcfa = 500;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartProvider);
    final subtotal =
        lines.fold<double>(0, (sum, line) => sum + line.lineTotal);
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
                          onPressed: () => _showOrderTypeBottomSheet(context, ref),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showOrderTypeBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Comment souhaitez-vous commander ?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Option sur place
            _OrderTypeOption(
              icon: Icons.restaurant_rounded,
              title: "🍽️ Manger sur place",
              subtitle: "Je viens au restaurant avec mon QR code",
              onTap: () {
                Navigator.pop(ctx);
                _showSurPlaceDialog(context, ref);
              },
            ),
            const SizedBox(height: 12),
            // Option livraison
            _OrderTypeOption(
              icon: Icons.delivery_dining_rounded,
              title: "🛵 Me faire livrer",
              subtitle: "Livraison à mon adresse",
              onTap: () {
                Navigator.pop(ctx);
                context.push("/ozelfoods/checkout");
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSurPlaceDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController heureCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Manger sur place"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: heureCtrl,
              decoration: const InputDecoration(
                labelText: "Heure d'arrivée prévue",
                hintText: "Ex: 12h30",
                prefixIcon: Icon(Icons.access_time_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          FilledButton(
            onPressed: () {
              final user = ref.read(authSessionProvider).user;
              final plats = ref.read(cartProvider).map((l) => l.item.name).toList();
              final restaurant = ref.read(cartProvider).isNotEmpty
                  ? ref.read(cartProvider).first.restaurantName
                  : "";
              Navigator.pop(ctx);
              context.push(
                "/ozelfoods/qrcode",
                extra: {
                  "commandeId":
                      "CMD-${DateTime.now().millisecondsSinceEpoch}",
                  "restaurantNom": restaurant,
                  "plats": plats,
                  "heurePrevue": heureCtrl.text,
                  "clientNom": user?.displayName ?? "Client Ozel",
                },
              );
            },
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
  }
}

class _OrderTypeOption extends StatelessWidget {
  const _OrderTypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

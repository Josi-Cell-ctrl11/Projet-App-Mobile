import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/constants/app_constants.dart";
import "../../../core/payment/fedapay_webview_screen.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/utils/food_business_rules.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../../shared/widgets/ozel_text_field.dart";
import "../../auth/application/auth_session.dart";
import "../application/cart_notifier.dart";
import "../application/food_orders_notifier.dart";
import "cart_screen.dart";

/// Zones de livraison avec frais
enum DeliveryZone {
  cotonouCentre(label: "📍 Cotonou centre", feeFcfa: 1000),
  cotonouPeripherie(label: "📍 Cotonou périphérie", feeFcfa: 1500),
  calavi(label: "📍 Calavi / Abomey-Calavi", feeFcfa: 2000),
  autreZone(label: "📍 Autre zone", feeFcfa: 2500);

  final String label;
  final double feeFcfa;

  const DeliveryZone({required this.label, required this.feeFcfa});
}

/// Mode de paiement du repas (FedaPay gère MTN/Moov/Visa dans la WebView).
enum FoodPaymentMode {
  full(label: "Payer tout maintenant", fraction: 1.0),
  deposit50(label: "Payer l'acompte (50%)", fraction: 0.5);

  const FoodPaymentMode({required this.label, required this.fraction});

  final String label;
  final double fraction;
}

/// Checkout OzelFoods — logique rapport client :
/// - Paiement du repas obligatoire a l'avance (MoMo)
/// - Frais de livraison affiches separement, regles a la remise
/// - Timer validation restaurant (3 min)
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _address = TextEditingController(
    text: "Haie Vive, Cotonou — pres de St Michel",
  );
  DeliveryZone _zone = DeliveryZone.cotonouCentre;
  FoodPaymentMode _paymentMode = FoodPaymentMode.full;
  bool _simulateLate = false;
  bool _simulateRestaurantReject = false;
  bool _loading = false;

  double get deliveryFee => _zone.feeFcfa;

  double _amountToPayNow(double subtotal) =>
      subtotal * _paymentMode.fraction;

  double _remainingMealBalance(double subtotal) =>
      _paymentMode == FoodPaymentMode.deposit50 ? subtotal * 0.5 : 0;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Panier vide.")),
      );
      return;
    }

    final subtotal = ref.read(cartProvider.notifier).subtotal;
    final amountNow = _amountToPayNow(subtotal);
    final soldeRepas = _remainingMealBalance(subtotal);

    if (!FoodBusinessRules.meetsMinimumOrder(
      subtotal,
      AppConstants.minFoodOrderFcfa,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Minimum ${Formatters.fcfa(AppConstants.minFoodOrderFcfa)} requis.",
          ),
        ),
      );
      return;
    }

    // Confirmation avant paiement : rappel regles
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Confirmer la commande",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recap paiement
            _PaymentRow(
              label: "Cout du repas",
              amount: subtotal,
              color: AppColors.black,
            ),
            const SizedBox(height: 8),
            _PaymentRow(
              label: "Frais de livraison",
              amount: deliveryFee,
              color: AppColors.textSecondary,
              note: "A regler a la remise",
            ),
            const Divider(height: 20),
            _PaymentRow(
              label: "A payer maintenant",
              amount: amountNow,
              color: AppColors.primary,
              isBold: true,
            ),
            if (soldeRepas > 0) ...[
              const SizedBox(height: 8),
              _PaymentRow(
                label: "Solde repas a la remise",
                amount: soldeRepas,
                color: AppColors.textSecondary,
                note: "Regle au livreur avec les frais de livraison",
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Les frais de livraison (${Formatters.fcfa(deliveryFee)}) sont regles "
                      "directement au livreur a la remise du repas.",
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text("Payer ${Formatters.fcfa(amountNow)}"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);

    // Récupérer restaurantName et user avant le paiement
    final restaurantName = cart.first.restaurantName;
    final user = ref.read(authSessionProvider).user;

    final paid = await lancerPaiementFedaPay(
      context: context,
      montant: amountNow,
      description: "OzelFoods — $restaurantName",
      customerName: user?.displayName ?? "Client Ozel",
      customerPhone: user?.phone ?? "",
      customerEmail: user?.email ?? "",
    );
    setState(() => _loading = false);
    if (!mounted || !paid) return;

    final order = await ref.read(foodOrdersProvider.notifier).startOrder(
          restaurantName: restaurantName,
          totalFcfa: subtotal + deliveryFee,
          userId: user?.id ?? "",
          restaurantAccepted: !_simulateRestaurantReject,
          lateMinutes: _simulateLate ? 20 : 0,
        );

    // Points Ozel : 1 FCFA = 1 point sur le montant paye via FedaPay
    if (user != null) {
      final gained = AppConstants.fcfaToPoints(amountNow);
      await ref.read(authSessionProvider.notifier).updateUser(
            user.copyWith(ozelPoints: user.ozelPoints + gained),
          );
    }

    ref.read(cartProvider.notifier).clear();
    if (!mounted) return;
    context.go("/ozelfoods/suivi/${order.id}");
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final subtotal = ref.read(cartProvider.notifier).subtotal;
    final amountNow = _amountToPayNow(subtotal);
    final soldeRepas = _remainingMealBalance(subtotal);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Finaliser la commande",
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.black),
        ),
      ),
      body: cart.isEmpty
          ? const Center(child: Text("Panier vide."))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Adresse de livraison ──────────────────────────────────────
                _SectionTitle(
                    icon: Icons.place_rounded, label: "Adresse de livraison"),
                const SizedBox(height: 10),
                OzelTextField(
                  controller: _address,
                  label: "Adresse complete",
                  maxLines: 2,
                  prefixIcon: Icons.place_outlined,
                ),

                const SizedBox(height: 20),

                // ── Zone de livraison ───────────────────────────────────────────
                _SectionTitle(
                    icon: Icons.location_on_rounded, label: "Zone de livraison"),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: DeliveryZone.values.map((zone) {
                      final selected = zone == _zone;
                      return GestureDetector(
                        onTap: () => setState(() => _zone = zone),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withValues(alpha: 0.06)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: selected
                                ? Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.3))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  zone.label,
                                  style: TextStyle(
                                    fontWeight:
                                        selected ? FontWeight.w700 : FontWeight.w400,
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.black,
                                  ),
                                ),
                              ),
                              Text(
                                Formatters.fcfa(zone.feeFcfa),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (selected)
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.primary, size: 20),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Recapitulatif paiement ────────────────────────────────────
                _SectionTitle(
                    icon: Icons.receipt_long_rounded,
                    label: "Recapitulatif"),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    children: [
                      // Lignes du panier
                      ...cart.map((line) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${line.item.name} x${line.quantity}",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Text(
                                  Formatters.fcfa(line.lineTotal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: 16),
                      // Cout repas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Cout du repas",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            Formatters.fcfa(subtotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Frais livraison
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Frais de livraison",
                                style: TextStyle(
                                    color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.warning
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "A la remise",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            Formatters.fcfa(deliveryFee),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      // A payer maintenant
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "A payer maintenant",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            Formatters.fcfa(amountNow),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      if (soldeRepas > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Solde repas a la remise",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              Formatters.fcfa(soldeRepas),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Info frais livraison
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.delivery_dining_rounded,
                          color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Les frais de livraison (${Formatters.fcfa(deliveryFee)}) sont regles "
                          "directement au livreur lors de la remise du repas. "
                          "Sans paiement, le livreur ne remet pas le repas.",
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Mode de paiement ──────────────────────────────────────────
                _SectionTitle(
                    icon: Icons.payments_rounded,
                    label: "Mode de paiement"),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: FoodPaymentMode.values.map((mode) {
                      final selected = mode == _paymentMode;
                      return GestureDetector(
                        onTap: () => setState(() => _paymentMode = mode),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withValues(alpha: 0.06)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: selected
                                ? Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3))
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    mode == FoodPaymentMode.full
                                        ? Icons.payments_rounded
                                        : Icons.savings_outlined,
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      mode.label,
                                      style: TextStyle(
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: selected
                                            ? AppColors.primary
                                            : AppColors.black,
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    const Icon(Icons.check_circle_rounded,
                                        color: AppColors.primary, size: 20),
                                ],
                              ),
                              if (mode == FoodPaymentMode.deposit50 &&
                                  selected) ...[
                                const SizedBox(height: 8),
                                Text(
                                  "Le solde de ${Formatters.fcfa(soldeRepas)} sera regle "
                                  "au livreur a la remise.",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.warning,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Options de simulation (debug) ─────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.disabled),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Simulation (debug)",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SwitchListTile(
                        dense: true,
                        title: const Text(
                          "Retard livreur > 15 min",
                          style: TextStyle(fontSize: 13),
                        ),
                        subtitle: const Text(
                          "Remboursement 10% en points Ozel",
                          style: TextStyle(fontSize: 11),
                        ),
                        value: _simulateLate,
                        onChanged: (v) => setState(() => _simulateLate = v),
                        activeColor: AppColors.primary,
                      ),
                      SwitchListTile(
                        dense: true,
                        title: const Text(
                          "Restaurant ne repond pas",
                          style: TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          "Annulation auto apres "
                          "${AppConstants.restaurantAcceptanceMinutes} min",
                          style: const TextStyle(fontSize: 11),
                        ),
                        value: _simulateRestaurantReject,
                        onChanged: (v) =>
                            setState(() => _simulateRestaurantReject = v),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                OzelPrimaryButton(
                  label: _loading
                      ? "Paiement en cours..."
                      : "Payer ${Formatters.fcfa(amountNow)} (repas)",
                  enabled: !_loading,
                  onPressed: _pay,
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    "Paiement securise via FedaPay — MTN, Moov ou Visa sur la page de paiement",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

// ─── Widgets helpers ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.label,
    required this.amount,
    required this.color,
    this.note,
    this.isBold = false,
  });
  final String label;
  final double amount;
  final Color color;
  final String? note;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                fontSize: isBold ? 14 : 13,
              ),
            ),
            if (note != null)
              Text(
                note!,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        Text(
          Formatters.fcfa(amount),
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: isBold ? 16 : 13,
          ),
        ),
      ],
    );
  }
}

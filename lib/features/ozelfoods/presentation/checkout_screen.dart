import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";

import "../../../core/constants/app_constants.dart";
import "../../../core/payment/fedapay_service.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/utils/food_business_rules.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../../shared/widgets/ozel_text_field.dart";
import "../../auth/application/auth_session.dart";
import "../application/cart_notifier.dart";
import "../application/food_orders_notifier.dart";
import "cart_screen.dart";

/// Checkout : adresse GPS (carte), moyen de paiement, simulation métier.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _address = TextEditingController(
    text: "Haie Vive, Cotonou — près de St Michel",
  );
  PaymentMethod _method = PaymentMethod.mtnMomo;
  bool _simulateLate = false;
  bool _simulateRestaurantReject = false;
  bool _loading = false;

  /// Position mock (Cotonou) pour la carte.
  static const LatLng _cotonou = LatLng(6.3725, 2.3544);

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
    setState(() => _loading = true);
    final fedapay = FedaPayService();
    final total = subtotal + CartScreen.deliveryFeeFcfa;
    final res = await fedapay.pay(amountFcfa: total, method: _method);
    setState(() => _loading = false);
    if (!mounted || !res.success) return;

    final restaurantName = cart.first.restaurantName;
    final order = ref.read(foodOrdersProvider.notifier).startOrder(
          restaurantName: restaurantName,
          totalFcfa: total,
          restaurantAccepted: !_simulateRestaurantReject,
          lateMinutes: _simulateLate ? 20 : 0,
        );

    // Points Ozel : 1 FCFA = 1 point sur le total payé.
    final user = ref.read(authSessionProvider).user;
    if (user != null) {
      final gained = AppConstants.fcfaToPoints(total);
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
    final total = subtotal + CartScreen.deliveryFeeFcfa;
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: cart.isEmpty
          ? const Center(child: Text("Panier vide."))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Adresse de livraison",
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: _cotonou,
                        zoom: 14,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId("drop"),
                          position: _cotonou,
                        ),
                      },
                      liteModeEnabled: true,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OzelTextField(
                  controller: _address,
                  label: "Adresse complète",
                  maxLines: 2,
                  prefixIcon: Icons.place_outlined,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Paiement (FedaPay — simulation)",
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...PaymentMethod.values.map((m) {
                  return RadioListTile<PaymentMethod>(
                    value: m,
                    groupValue: _method,
                    onChanged: (v) => setState(() => _method = v!),
                    title: Text(m.labelFr),
                  );
                }),
                SwitchListTile(
                  title: const Text("Simuler retard livreur > 15 min"),
                  subtitle: const Text(
                    "Affiche le remboursement 10 % en points Ozel (règle métier).",
                  ),
                  value: _simulateLate,
                  onChanged: (v) => setState(() => _simulateLate = v),
                ),
                SwitchListTile(
                  title: const Text("Simuler non acceptation restaurant"),
                  subtitle: Text(
                    "Si le restaurant n’accepte pas sous "
                    "${AppConstants.restaurantAcceptanceMinutes} min → annulation auto (UI).",
                  ),
                  value: _simulateRestaurantReject,
                  onChanged: (v) =>
                      setState(() => _simulateRestaurantReject = v),
                ),
                const Divider(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total à payer"),
                    Text(
                      Formatters.fcfa(total),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OzelPrimaryButton(
                  label: _loading ? "Paiement..." : "Payer et commander",
                  enabled: !_loading,
                  onPressed: _pay,
                ),
              ],
            ),
    );
  }
}

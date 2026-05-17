import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:uuid/uuid.dart";

import "../../../core/payment/fedapay_service.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../../../core/utils/rapid_colis_pricing.dart";
import "../../../shared/models/colis_shipment.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../wallet/application/wallet_notifier.dart";
import "../application/active_colis_notifier.dart";
import "../application/colis_draft_notifier.dart";

/// Confirmation + paiement FedaPay (simulation).
class ColisConfirmScreen extends ConsumerStatefulWidget {
  const ColisConfirmScreen({super.key});

  @override
  ConsumerState<ColisConfirmScreen> createState() => _ColisConfirmScreenState();
}

class _ColisConfirmScreenState extends ConsumerState<ColisConfirmScreen> {
  PaymentMethod _method = PaymentMethod.moovMoney;
  bool _loading = false;

  Future<void> _pay() async {
    final draft = ref.read(colisDraftProvider);
    final price = RapidColisPricing.quote(
      distanceKm: draft.distanceKm,
      weightKg: draft.weightKg,
    );
    setState(() => _loading = true);
    final res = await FedaPayService().pay(amountFcfa: price, method: _method);
    setState(() => _loading = false);
    if (!mounted || !res.success) return;

    ref.read(walletTxProvider.notifier).addDebit(
          "Rapid Colis (${draft.pointA} → ${draft.pointB})",
          price,
        );

    final shipment = ColisShipment(
      id: Uuid().v4(),
      pointA: draft.pointA,
      pointB: draft.pointB,
      weightKg: draft.weightKg,
      distanceKm: draft.distanceKm,
      priceFcfa: price,
      photoPath: draft.photoPath,
      driverLat: 6.37,
      driverLng: 2.35,
    );
    ref.read(activeColisProvider.notifier).setShipment(shipment);
    ref.read(colisDraftProvider.notifier).reset();
    if (!mounted) return;
    context.go("/rapid-colis/suivi");
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(colisDraftProvider);
    final price = RapidColisPricing.quote(
      distanceKm: draft.distanceKm,
      weightKg: draft.weightKg,
    );
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement colis")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            Formatters.fcfa(price),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...PaymentMethod.values.map(
            (m) => RadioListTile<PaymentMethod>(
              value: m,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
              title: Text(m.labelFr),
            ),
          ),
          const SizedBox(height: 8),
          OzelPrimaryButton(
            label: _loading ? "Paiement..." : "Payer avec FedaPay (mock)",
            enabled: !_loading,
            onPressed: _pay,
          ),
        ],
      ),
    );
  }
}

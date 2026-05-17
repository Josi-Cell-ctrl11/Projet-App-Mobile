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

/// Confirmation + paiement Rapid Colis.
/// Logique rapport client :
/// - Si expediteur paie : paiement maintenant avant collecte
/// - Si destinataire paie : paiement a la remise (livreur attend confirmation)
/// - Message "paiement avant remise" toujours visible
class ColisConfirmScreen extends ConsumerStatefulWidget {
  const ColisConfirmScreen({super.key});

  @override
  ConsumerState<ColisConfirmScreen> createState() =>
      _ColisConfirmScreenState();
}

class _ColisConfirmScreenState extends ConsumerState<ColisConfirmScreen> {
  PaymentMethod _method = PaymentMethod.moovMoney;
  bool _loading = false;

  Future<void> _pay() async {
    final draft = ref.read(colisDraftProvider);
    final price = RapidColisPricing.quote(
      distanceKm: draft.distanceKm,
      weightKg: 1, // poids sera confirme par le livreur
    );

    setState(() => _loading = true);
    final res = await FedaPayService().pay(amountFcfa: price, method: _method);
    setState(() => _loading = false);
    if (!mounted || !res.success) return;

    ref.read(walletTxProvider.notifier).addDebit(
          "Rapid Colis (${draft.pointA} -> ${draft.pointB})",
          price,
        );

    final shipment = ColisShipment(
      id: const Uuid().v4(),
      pointA: draft.pointA,
      pointB: draft.pointB,
      weightKg: 1,
      distanceKm: draft.distanceKm,
      priceFcfa: price,
      photoPath: draft.photoPath,
      payeur: draft.payeur,
      nomDestinataire: draft.nomDestinataire,
      telephoneDestinataire: draft.telephoneDestinataire,
      mode: draft.mode,
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
      weightKg: 1,
    );
    final payeurEstExpediteur = draft.payeur == PayeurColis.expediteur;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "Confirmation",
          style: TextStyle(
              fontWeight: FontWeight.w800, color: AppColors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Prix estimatif ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Prix estimatif",
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  Formatters.fcfa(price),
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Prix final confirme apres pesee par le livreur",
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Recap commande ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.flag_rounded,
                  iconColor: AppColors.success,
                  label: "Depart",
                  value: draft.pointA,
                ),
                const _Divider(),
                _DetailRow(
                  icon: Icons.place_rounded,
                  iconColor: const Color(0xFF1565C0),
                  label: "Arrivee",
                  value: draft.pointB,
                ),
                if (draft.nomDestinataire.isNotEmpty) ...[
                  const _Divider(),
                  _DetailRow(
                    icon: Icons.person_rounded,
                    iconColor: AppColors.textSecondary,
                    label: "Destinataire",
                    value: draft.nomDestinataire,
                  ),
                ],
                if (draft.telephoneDestinataire.isNotEmpty) ...[
                  const _Divider(),
                  _DetailRow(
                    icon: Icons.phone_rounded,
                    iconColor: AppColors.textSecondary,
                    label: "Tel",
                    value: draft.telephoneDestinataire,
                  ),
                ],
                const _Divider(),
                _DetailRow(
                  icon: Icons.route_rounded,
                  iconColor: AppColors.primary,
                  label: "Distance",
                  value: "${draft.distanceKm.toStringAsFixed(1)} km",
                ),
                const _Divider(),
                _DetailRow(
                  icon: Icons.payments_rounded,
                  iconColor: payeurEstExpediteur
                      ? AppColors.primary
                      : AppColors.warning,
                  label: "Qui paie",
                  value: payeurEstExpediteur
                      ? "Vous (expediteur)"
                      : "Le destinataire",
                ),
                const _Divider(),
                _DetailRow(
                  icon: draft.mode == ModeColis.colis
                      ? Icons.inventory_2_rounded
                      : Icons.directions_bike_rounded,
                  iconColor: AppColors.textSecondary,
                  label: "Mode",
                  value: draft.mode == ModeColis.colis
                      ? "Colis standard"
                      : "Coursier universel",
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Message paiement avant remise ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFFB71C1C).withValues(alpha: 0.25)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_rounded,
                    color: Color(0xFFB71C1C), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Le paiement doit etre effectue avant la remise du colis. "
                    "Aucun colis ne peut etre remis sans confirmation de paiement.",
                    style: TextStyle(
                      color: Color(0xFFB71C1C),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Qui paie : logique affichage ───────────────────────────────────
          if (!payeurEstExpediteur)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.25)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.warning, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Paiement par le destinataire",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Le livreur initiera le paiement via l'application a la "
                    "destination et attendra la confirmation avant de remettre "
                    "le colis. En cas de non-paiement persistant, le colis sera "
                    "depose au commissariat le plus proche.",
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // ── Moyen de paiement (si expediteur paie) ─────────────────────────
          if (payeurEstExpediteur) ...[
            const Row(
              children: [
                Icon(Icons.payment_rounded,
                    size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  "Moyen de paiement",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: PaymentMethod.values.map((m) {
                  final sel = m == _method;
                  return GestureDetector(
                    onTap: () => setState(() => _method = m),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primary.withValues(alpha: 0.06)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: sel
                            ? Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.3))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone_android_rounded,
                            color: sel
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              m.labelFr,
                              style: TextStyle(
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.black,
                              ),
                            ),
                          ),
                          if (sel)
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
          ],

          // ── Bouton ─────────────────────────────────────────────────────────
          OzelPrimaryButton(
            label: _loading
                ? "Traitement..."
                : payeurEstExpediteur
                    ? "Payer ${Formatters.fcfa(price)} et envoyer"
                    : "Confirmer l'envoi (paiement a la remise)",
            enabled: !_loading,
            onPressed: _pay,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Widgets helpers ──────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: AppColors.surface);
}

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:uuid/uuid.dart";

import "../../../core/payment/fedapay_service.dart";
import "../../../core/payment/fedapay_webview_screen.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../../../core/utils/rapid_colis_pricing.dart";
import "../../../shared/models/colis_shipment.dart";
import "../../../shared/widgets/ozel_button.dart";
import "../../auth/application/auth_session.dart";
import "../../wallet/application/wallet_notifier.dart";
import "../application/active_colis_notifier.dart";
import "../application/colis_draft_notifier.dart";

const Color _orange = Color(0xFFFF6B35);
const Color _lightGray = Color(0xFFF8F8F8);
const Color _darkGray = Color(0xFF333333);
const Color _lightOrange = Color(0xFFFFF3EE);

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
      weightKg: 1,
    );

    final user = ref.read(authSessionProvider).user;
    setState(() => _loading = true);
    final paid = await lancerPaiementFedaPay(
      context: context,
      montant: price,
      description: "Rapid Colis — ${draft.pointA} → ${draft.pointB}",
      customerName: user?.name ?? "Client Ozel",
      customerPhone: user?.phone ?? "",
      customerEmail: user?.email ?? "",
    );
    setState(() => _loading = false);
    if (!mounted || !paid) return;

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
      destinatairePrenom: draft.destinatairePrenom,
      destinataireNom: draft.destinataireNom,
      destinataireTelephone: draft.destinataireTelephone,
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
      backgroundColor: _lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _darkGray),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Confirmation",
          style: TextStyle(
              fontWeight: FontWeight.w800, color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Success icon ─────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Tracking number ─────────────────────────────────────────────────
          Center(
            child: Text(
              "#RC-${const Uuid().v4().substring(0, 6).toUpperCase()}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              "Numéro de suivi",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Recap card ───────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_rounded,
                        size: 16, color: _darkGray),
                    const SizedBox(width: 8),
                    const Text(
                      "Expéditeur",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text("|"),
                    const SizedBox(width: 16),
                    const Icon(Icons.person_outline_rounded,
                        size: 16, color: _darkGray),
                    const SizedBox(width: 8),
                    Text(
                      "${draft.destinatairePrenom} ${draft.destinataireNom}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.flag_rounded,
                  label: "De",
                  value: draft.pointA,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.place_rounded,
                  label: "Vers",
                  value: draft.pointB,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.scale_rounded,
                  label: "Poids",
                  value: "Mesure par le livreur",
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.payments_rounded,
                  label: "Montant",
                  value: Formatters.fcfa(price),
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.credit_card_rounded,
                  label: "Mode paiement",
                  value: payeurEstExpediteur
                      ? "Vous (expéditeur)"
                      : "Le destinataire",
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Boutons ───────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _pay,
              style: FilledButton.styleFrom(
                backgroundColor: _orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _loading
                    ? "Traitement..."
                    : payeurEstExpediteur
                        ? "Payer ${Formatters.fcfa(price)} et envoyer"
                        : "Confirmer l'envoi (paiement à la remise)",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Téléchargement du reçu PDF (bientôt disponible)"),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _orange,
                side: BorderSide(color: _orange, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Télécharger le reçu PDF",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
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
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _darkGray),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

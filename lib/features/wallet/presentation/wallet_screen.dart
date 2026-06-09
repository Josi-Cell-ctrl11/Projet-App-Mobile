import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/constants/app_constants.dart";
import "../../../core/payment/fedapay_webview_screen.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/models/wallet_transaction.dart";
import "../../auth/application/auth_session.dart";
import "../application/wallet_notifier.dart";

/// OzelWallet — Points de fidélité + historique des transactions.
/// Le paiement se fait directement au moment de chaque service (MoMo/Moov).
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider).user;
    final txs = ref.watch(walletTxProvider);
    final points = user?.ozelPoints ?? 0;
    final seuil = AppConstants.pointsPourLivraisonGratuite;
    final progression = (points % seuil) / seuil;
    final pointsRestants = seuil - (points % seuil);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── Header gradient ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _WalletHeader(points: points),
            ),
            title: const Text(
              "OzelWallet",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Carte progression ──────────────────────────────────────
                  _ProgressCard(
                    points: points,
                    progression: progression,
                    pointsRestants: pointsRestants,
                    seuil: seuil,
                  ),
                  const SizedBox(height: 20),

                  // ── Avantages points ───────────────────────────────────────
                  const _AvantagesSection(),
                  const SizedBox(height: 20),

                  // ── Bouton recharge wallet ─────────────────────────────────
                  _RechargeButton(user: user),
                  const SizedBox(height: 24),

                  // ── Historique ─────────────────────────────────────────────
                  Row(
                    children: [
                      const Text(
                        "Historique",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${txs.length} opérations",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ── Liste transactions ─────────────────────────────────────────────
          txs.isEmpty
              ? const SliverToBoxAdapter(child: _EmptyHistory())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList.separated(
                    itemCount: txs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _TxCard(tx: txs[i]),
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Bouton recharge wallet ─────────────────────────────────────────────────

class _RechargeButton extends ConsumerStatefulWidget {
  const _RechargeButton({required this.user});
  final dynamic user;

  @override
  ConsumerState<_RechargeButton> createState() => _RechargeButtonState();
}

class _RechargeButtonState extends ConsumerState<_RechargeButton> {
  bool _loading = false;

  static const List<double> _montants = [1000, 2000, 5000, 10000];

  Future<void> _recharger() async {
    // Choisir le montant
    final montant = await showModalBottomSheet<double>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _MontantPicker(montants: _montants),
    );
    if (montant == null || !mounted) return;

    setState(() => _loading = true);

    final paid = await lancerPaiementFedaPay(
      context: context,
      montant: montant,
      description: "Recharge OzelWallet",
      customerName: widget.user?.displayName ?? "Client Ozel",
      customerPhone: widget.user?.phone ?? "",
      customerEmail: widget.user?.email ?? "",
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (paid) {
      await ref
          .read(walletTxProvider.notifier)
          .addCredit("Recharge OzelWallet", montant);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Recharge de ${Formatters.fcfa(montant)} effectuée ✓"),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _recharger,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        icon: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              )
            : const Icon(Icons.add_rounded),
        label: Text(
          _loading ? "Traitement..." : "Recharger mon wallet",
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _MontantPicker extends StatelessWidget {
  const _MontantPicker({required this.montants});
  final List<double> montants;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Choisir le montant",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.black),
          ),
          const SizedBox(height: 16),
          ...montants.map((m) => ListTile(
                onTap: () => Navigator.pop(context, m),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.primary, size: 20),
                ),
                title: Text(
                  Formatters.fcfa(m),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
              )),
        ],
      ),
    );
  }
}

// ── Header avec cercle de points ─────────────────────────────────────────────

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({required this.points});
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFE64A19)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Cercles décoratifs
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Contenu
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Mes Points Ozel",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$points",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 8),
                      child: Text(
                        "pts",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "1 point = 1 FCFA de réduction",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte progression vers récompense ────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.points,
    required this.progression,
    required this.pointsRestants,
    required this.seuil,
  });

  final int points;
  final double progression;
  final int pointsRestants;
  final int seuil;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Prochaine livraison gratuite",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.black,
                  ),
                ),
              ),
              Text(
                "${(progression * 100).toInt()}%",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progression,
              backgroundColor: AppColors.surface,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            pointsRestants == 0
                ? "🎉 Livraison gratuite disponible !"
                : "Plus que $pointsRestants pts sur $seuil",
            style: TextStyle(
              fontSize: 13,
              color: pointsRestants == 0
                  ? AppColors.success
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section avantages ─────────────────────────────────────────────────────────

class _AvantagesSection extends StatelessWidget {
  const _AvantagesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Comment gagner des points ?",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AvantageChip(
                icon: Icons.restaurant_rounded,
                label: "OzelFoods",
                detail: "1 FCFA = 1 pt",
                color: const Color(0xFFE64A19),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AvantageChip(
                icon: Icons.local_shipping_rounded,
                label: "Rapid Colis",
                detail: "1 FCFA = 1 pt",
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AvantageChip(
                icon: Icons.event_rounded,
                label: "Ozel Event",
                detail: "1 FCFA = 1 pt",
                color: const Color(0xFF6A1B9A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AvantageChip extends StatelessWidget {
  const _AvantageChip({
    required this.icon,
    required this.label,
    required this.detail,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Carte transaction ─────────────────────────────────────────────────────────

class _TxCard extends StatelessWidget {
  const _TxCard({required this.tx});
  final WalletTransaction tx;

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.type == WalletTxType.credit;
    final color = isCredit ? AppColors.success : AppColors.primary;
    final bgColor = isCredit
        ? AppColors.success.withValues(alpha: 0.08)
        : AppColors.primary.withValues(alpha: 0.08);

    return Container(
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit
                  ? Icons.add_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "${tx.createdAt.day.toString().padLeft(2, '0')}/"
                  "${tx.createdAt.month.toString().padLeft(2, '0')}/"
                  "${tx.createdAt.year}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isCredit ? '+' : '-'}${Formatters.fcfa(tx.amountFcfa)}",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isCredit ? "Points gagnés" : "Dépense",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Historique vide ───────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            "Aucune transaction pour l'instant",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Commandez un service pour commencer\nà gagner des points",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

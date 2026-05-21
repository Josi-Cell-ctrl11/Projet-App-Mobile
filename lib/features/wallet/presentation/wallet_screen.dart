import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/constants/app_constants.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/utils/formatters.dart";
import "../../../shared/models/wallet_transaction.dart";
import "../../auth/application/auth_session.dart";
import "../application/wallet_notifier.dart";

/// OzelWallet : solde + historique + accès recharge.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider).user;
    final txs = ref.watch(walletTxProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("OzelWallet")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Solde wallet ─────────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Solde disponible",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user == null
                        ? "—"
                        : Formatters.fcfa(user.walletBalanceFcfa),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => context.push("/wallet/recharge"),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    icon: const Icon(Icons.add_card_rounded),
                    label: const Text("Recharger (MoMo / FedaPay mock)"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Points Ozel ────────────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        "Mes Points Ozel",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user == null ? "—" : "${user.ozelPoints} points",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "1 FCFA = 1 point • 1 point = 1 FCFA de réduction",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Barre de progression vers livraison gratuite
                  if (user != null) ...[
                    const Text(
                      "Progression vers livraison gratuite",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (user.ozelPoints % AppConstants.pointsPourLivraisonGratuite) /
                            AppConstants.pointsPourLivraisonGratuite,
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Plus que ${AppConstants.pointsPourLivraisonGratuite - (user.ozelPoints % AppConstants.pointsPourLivraisonGratuite)} points pour une livraison gratuite !",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Historique points (mock)
                  const Text(
                    "Historique des points",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PointsHistoryItem(
                    label: "Commande OzelFoods",
                    points: 150,
                    date: "20/05/2026",
                  ),
                  _PointsHistoryItem(
                    label: "Inscription bonus",
                    points: 500,
                    date: "15/05/2026",
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Historique wallet ───────────────────────────────────────────────────
          const Text(
            "Historique",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...txs.map((t) {
            final isCredit = t.type == WalletTxType.credit;
            return Card(
              child: ListTile(
                leading: Icon(
                  isCredit ? Icons.trending_up : Icons.trending_down,
                  color: isCredit ? AppColors.success : AppColors.primary,
                ),
                title: Text(t.label),
                subtitle: Text(
                  "${t.createdAt.day.toString().padLeft(2, "0")}/"
                  "${t.createdAt.month.toString().padLeft(2, "0")}/"
                  "${t.createdAt.year}",
                ),
                trailing: Text(
                  "${isCredit ? "+" : "-"}${Formatters.fcfa(t.amountFcfa)}",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PointsHistoryItem extends StatelessWidget {
  const _PointsHistoryItem({
    required this.label,
    required this.points,
    required this.date,
  });

  final String label;
  final int points;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "+$points pts",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

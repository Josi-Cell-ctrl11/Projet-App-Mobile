import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Solde disponible",
                    style: const TextStyle(color: AppColors.textSecondary),
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
                  const SizedBox(height: 6),
                  Text(
                    user == null
                        ? "Connecte-toi pour voir ton solde."
                        : "Points Ozel : ${user.ozelPoints} (1 FCFA = 1 point)",
                    style: const TextStyle(color: AppColors.textSecondary),
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
          const Text(
            "Historique",
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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

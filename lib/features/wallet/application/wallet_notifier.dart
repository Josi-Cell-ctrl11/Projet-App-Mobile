import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../shared/models/wallet_transaction.dart";

/// Historique wallet mock + mutations simples.
class WalletNotifier extends Notifier<List<WalletTransaction>> {
  @override
  List<WalletTransaction> build() => [
        WalletTransaction(
          id: "tx1",
          label: "Cashback OzelFoods",
          amountFcfa: 500,
          type: WalletTxType.credit,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        WalletTransaction(
          id: "tx2",
          label: "Livraison Rapid Colis",
          amountFcfa: 2500,
          type: WalletTxType.debit,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];

  void addCredit(String label, double amountFcfa) {
    final tx = WalletTransaction(
      id: "tx-${DateTime.now().millisecondsSinceEpoch}",
      label: label,
      amountFcfa: amountFcfa,
      type: WalletTxType.credit,
      createdAt: DateTime.now(),
    );
    state = [tx, ...state];
  }

  void addDebit(String label, double amountFcfa) {
    final tx = WalletTransaction(
      id: "tx-${DateTime.now().millisecondsSinceEpoch}",
      label: label,
      amountFcfa: amountFcfa,
      type: WalletTxType.debit,
      createdAt: DateTime.now(),
    );
    state = [tx, ...state];
  }
}

final walletTxProvider = NotifierProvider<WalletNotifier, List<WalletTransaction>>(
  WalletNotifier.new,
);

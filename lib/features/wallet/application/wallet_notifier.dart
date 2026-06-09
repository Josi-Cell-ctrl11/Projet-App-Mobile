import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/services/firestore_service.dart";
import "../../../shared/models/wallet_transaction.dart";
import "../../auth/application/auth_session.dart";

/// Historique wallet — synchronisé avec Firestore.
class WalletNotifier extends Notifier<List<WalletTransaction>> {
  @override
  List<WalletTransaction> build() {
    // Écoute en temps réel si utilisateur connecté
    final uid = ref.watch(authSessionProvider).user?.id;
    if (uid != null) {
      FirestoreService.instance
          .walletStream(uid)
          .listen((snapshot) {
        state = snapshot.docs
            .map((doc) => WalletTransaction.fromJson(doc.data()))
            .toList();
      });
    }
    return [];
  }

  Future<void> addCredit(String label, double amountFcfa) =>
      _addTx(label, amountFcfa, WalletTxType.credit);

  Future<void> addDebit(String label, double amountFcfa) =>
      _addTx(label, amountFcfa, WalletTxType.debit);

  Future<void> _addTx(
      String label, double amountFcfa, WalletTxType type) async {
    final uid = ref.read(authSessionProvider).user?.id;
    final tx = WalletTransaction(
      id: "tx-${DateTime.now().millisecondsSinceEpoch}",
      label: label,
      amountFcfa: amountFcfa,
      type: type,
      createdAt: DateTime.now(),
    );

    // Mise à jour locale immédiate
    state = [tx, ...state];

    // Persistance Firestore
    if (uid != null) {
      try {
        await FirestoreService.instance
            .addWalletTransaction(uid, tx.toJson());
      } catch (_) {}
    }
  }
}

final walletTxProvider =
    NotifierProvider<WalletNotifier, List<WalletTransaction>>(
  WalletNotifier.new,
);

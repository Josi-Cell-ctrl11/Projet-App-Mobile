/// Transaction OzelWallet (mock).
enum WalletTxType { credit, debit }

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.label,
    required this.amountFcfa,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String label;
  final double amountFcfa;
  final WalletTxType type;
  final DateTime createdAt;
}

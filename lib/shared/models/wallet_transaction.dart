import "package:cloud_firestore/cloud_firestore.dart";

/// Transaction OzelWallet.
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

  Map<String, dynamic> toJson() => {
        "id": id,
        "label": label,
        "amountFcfa": amountFcfa,
        "type": type.name,
        "createdAt": Timestamp.fromDate(createdAt),
      };

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json["id"] as String? ?? "",
        label: json["label"] as String? ?? "",
        amountFcfa: (json["amountFcfa"] as num?)?.toDouble() ?? 0,
        type: WalletTxType.values.byName(
          json["type"] as String? ?? "credit",
        ),
        createdAt: json["createdAt"] is Timestamp
            ? (json["createdAt"] as Timestamp).toDate()
            : DateTime.now(),
      );
}

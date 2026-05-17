import "dart:async";

import "../constants/app_constants.dart";

/// Moyens de paiement disponibles (Bénin).
enum PaymentMethod { mtnMomo, moovMoney, visa, cash }

extension PaymentMethodLabel on PaymentMethod {
  String get labelFr {
    switch (this) {
      case PaymentMethod.mtnMomo:
        return "MTN MoMo";
      case PaymentMethod.moovMoney:
        return "Moov Money";
      case PaymentMethod.visa:
        return "Visa";
      case PaymentMethod.cash:
        return "Espèces à la livraison";
    }
  }
}

/// Service FedaPay — intégration réelle à brancher sur le SDK / API FedaPay.
/// Ici : simulation réseau pour le MVP.
class FedaPayService {
  FedaPayService({this.publicKey = AppConstants.fedapayPublicKeyPlaceholder});

  final String publicKey;

  /// Lance un paiement mock (succès après délai).
  Future<FedaPayMockResult> pay({
    required double amountFcfa,
    required PaymentMethod method,
  }) async {
    // Simulation latence réseau
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return FedaPayMockResult(
      success: true,
      transactionId: "fedapay_mock_${DateTime.now().millisecondsSinceEpoch}",
      message:
          "Paiement simulé via FedaPay (clé: $publicKey, méthode: ${method.labelFr}).",
    );
  }
}

class FedaPayMockResult {
  const FedaPayMockResult({
    required this.success,
    required this.transactionId,
    required this.message,
  });

  final bool success;
  final String transactionId;
  final String message;
}

import "dart:convert";

import "package:dio/dio.dart";

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

  String get fedapayMethod {
    switch (this) {
      case PaymentMethod.mtnMomo:
        return "mtn";
      case PaymentMethod.moovMoney:
        return "moov";
      case PaymentMethod.visa:
        return "card";
      case PaymentMethod.cash:
        return "cash";
    }
  }
}

/// Résultat d'un paiement FedaPay.
class FedaPayResult {
  const FedaPayResult({
    required this.success,
    required this.transactionId,
    required this.message,
    this.checkoutUrl,
  });

  final bool success;
  final String transactionId;
  final String message;

  /// URL de la page de paiement FedaPay (WebView).
  final String? checkoutUrl;
}

/// Service FedaPay — API REST sandbox/live.
/// Clés configurées dans app_constants.dart
class FedaPayService {
  static const String _sandboxUrl = "https://sandbox-api.fedapay.com/v1";
  static const String _liveUrl = "https://api.fedapay.com/v1";

  /// Mettre à true pour passer en production
  static const bool _isLive = false;

  static const String _secretKey =
      String.fromEnvironment("FEDAPAY_SECRET_KEY");

  static String get _baseUrl => _isLive ? _liveUrl : _sandboxUrl;

  static void _ensureSecretKey() {
    if (_secretKey.isEmpty) {
      throw StateError(
        "FEDAPAY_SECRET_KEY manquante. Passez --dart-define=FEDAPAY_SECRET_KEY=...",
      );
    }
  }

  final _dio = Dio();

  /// Crée une transaction FedaPay et retourne l'URL de paiement.
  Future<FedaPayResult> createTransaction({
    required double amountFcfa,
    required String description,
    required String customerEmail,
    required String customerPhone,
    required String customerName,
  }) async {
    _ensureSecretKey();
    try {
      final response = await _dio.post(
        "$_baseUrl/transactions",
        options: Options(
          headers: {
            "Authorization": "Bearer $_secretKey",
            "Content-Type": "application/json",
          },
        ),
        data: jsonEncode({
          "description": description,
          "amount": amountFcfa.toInt(),
          "currency": {"iso": "XOF"},
          "customer": {
            "email": customerEmail.isNotEmpty
                ? customerEmail
                : "client@ozelservices.bj",
            "firstname": customerName.split(" ").first,
            "lastname":
                customerName.split(" ").length > 1
                    ? customerName.split(" ").last
                    : "",
            "phone_number": {
              "number": customerPhone.replaceAll("+229", "").replaceAll(" ", ""),
              "country": "BJ",
            },
          },
          "callback_url": "https://ozelservices-payment.web.app/callback",
        }),
      );

      final txData = response.data["v1/transaction"] ??
          response.data["data"] ??
          response.data["transaction"];
      final txId = txData?["id"]?.toString() ?? "";

      // Générer le lien de paiement
      final tokenResponse = await _dio.post(
        "$_baseUrl/transactions/$txId/token",
        options: Options(
          headers: {
            "Authorization": "Bearer $_secretKey",
            "Content-Type": "application/json",
          },
        ),
      );

      final token =
          tokenResponse.data["token"]?.toString() ?? "";
      final checkoutUrl =
          "https://checkout${_isLive ? '' : '-sandbox'}.fedapay.com/$token";

      return FedaPayResult(
        success: true,
        transactionId: txId,
        message: "Transaction créée",
        checkoutUrl: checkoutUrl,
      );
    } catch (e) {
      return FedaPayResult(
        success: false,
        transactionId: "",
        message: "Erreur de paiement : $e",
      );
    }
  }

  /// Vérifie le statut d'une transaction.
  Future<bool> checkTransactionStatus(String transactionId) async {
    _ensureSecretKey();
    try {
      final response = await _dio.get(
        "$_baseUrl/transactions/$transactionId",
        options: Options(
          headers: {"Authorization": "Bearer $_secretKey"},
        ),
      );
      final txData = response.data["v1/transaction"] ??
          response.data["data"] ??
          response.data["transaction"];
      final status = txData?["status"]?.toString() ?? "";
      return status == "approved";
    } catch (_) {
      return false;
    }
  }
}

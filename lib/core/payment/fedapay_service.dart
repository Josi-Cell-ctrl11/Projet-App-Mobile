import "package:dio/dio.dart";

import "../config/payment_config.dart";

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
/// Clés dans lib/core/config/payment_secrets.dart (non versionné).
class FedaPayService {
  static const String _sandboxUrl = "https://sandbox-api.fedapay.com/v1";
  static const String _liveUrl = "https://api.fedapay.com/v1";

  static const bool _isLive = PaymentConfig.isLive;

  static const String _secretKey = PaymentConfig.secretKey;
  static const String publicKey = PaymentConfig.publicKey;

  static String get _baseUrl => _isLive ? _liveUrl : _sandboxUrl;

  static Map<String, String> get _headers => {
        "Authorization": "Bearer $_secretKey",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

  static void _ensureSecretKey() {
    if (_secretKey.isEmpty) {
      throw StateError(
        "FEDAPAY_SECRET_KEY manquante. Copiez payment_secrets.example.dart "
        "en payment_secrets.dart ou passez --dart-define=FEDAPAY_SECRET_KEY=...",
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
      final response = await _dio.post<Map<String, dynamic>>(
        "$_baseUrl/transactions",
        options: Options(headers: _headers),
        data: {
          "description": description,
          "amount": amountFcfa.toInt(),
          "currency": {"iso": "XOF"},
          "customer": {
            "email": customerEmail.isNotEmpty
                ? customerEmail
                : "client@ozelservices.bj",
            "firstname": customerName.split(" ").first,
            "lastname": customerName.split(" ").length > 1
                ? customerName.split(" ").last
                : "",
            "phone_number": {
              "number":
                  customerPhone.replaceAll("+229", "").replaceAll(" ", ""),
              "country": "BJ",
            },
          },
          "callback_url": "https://ozelservices-payment.web.app/callback",
        },
      );

      final txId = _extractTransactionId(response.data);
      if (txId == null || txId.isEmpty) {
        return const FedaPayResult(
          success: false,
          transactionId: "",
          message: "Erreur de paiement : identifiant transaction introuvable.",
        );
      }

      final tokenResponse = await _dio.post<Map<String, dynamic>>(
        "$_baseUrl/transactions/$txId/token",
        options: Options(headers: _headers),
      );

      final checkoutUrl = _extractCheckoutUrl(tokenResponse.data, txId);

      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        return FedaPayResult(
          success: false,
          transactionId: txId,
          message: "Erreur de paiement : URL de checkout introuvable.",
        );
      }

      return FedaPayResult(
        success: true,
        transactionId: txId,
        message: "Transaction créée",
        checkoutUrl: checkoutUrl,
      );
    } on DioException catch (e) {
      return FedaPayResult(
        success: false,
        transactionId: "",
        message: "Erreur de paiement : ${_dioErrorMessage(e)}",
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
      final response = await _dio.get<Map<String, dynamic>>(
        "$_baseUrl/transactions/$transactionId",
        options: Options(headers: _headers),
      );
      final txData = _extractTransactionMap(response.data);
      final status = txData?["status"]?.toString() ?? "";
      return status == "approved";
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static Map<String, dynamic>? _extractTransactionMap(dynamic data) {
    final root = _asMap(data);
    if (root == null) return null;

    return _asMap(root["v1/transaction"]) ??
        _asMap(root["data"]) ??
        _asMap(root["transaction"]) ??
        root;
  }

  static String? _extractTransactionId(dynamic data) {
    final tx = _extractTransactionMap(data);
    final id = tx?["id"];
    if (id == null) return null;
    return id.toString();
  }

  static String? _extractCheckoutUrl(dynamic tokenData, String txId) {
    final root = _asMap(tokenData);
    if (root == null) return null;

    final directUrl = root["url"]?.toString();
    if (directUrl != null && directUrl.isNotEmpty) return directUrl;

    for (final key in ["data", "v1/token"]) {
      final nested = _asMap(root[key]);
      final nestedUrl = nested?["url"]?.toString();
      if (nestedUrl != null && nestedUrl.isNotEmpty) return nestedUrl;
    }

    final token = root["token"]?.toString() ??
        _asMap(root["data"])?["token"]?.toString() ??
        "";
    if (token.isEmpty) return null;

    return "https://checkout${_isLive ? '' : '-sandbox'}.fedapay.com/$token";
  }

  static String _dioErrorMessage(DioException e) {
    final responseData = e.response?.data;
    if (responseData != null) {
      final map = _asMap(responseData);
      final message = map?["message"] ?? map?["error"];
      if (message != null) return message.toString();
      return responseData.toString();
    }
    return e.message ?? e.toString();
  }
}

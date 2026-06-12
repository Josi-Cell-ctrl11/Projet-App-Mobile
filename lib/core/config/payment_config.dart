import "payment_secrets.dart";

/// Configuration FedaPay — sandbox par défaut.
abstract final class PaymentConfig {
  static const bool isLive = false;

  static const String publicKey = String.fromEnvironment(
    "FEDAPAY_PUBLIC_KEY",
    defaultValue: PaymentSecrets.publicKey,
  );

  static const String secretKey = String.fromEnvironment(
    "FEDAPAY_SECRET_KEY",
    defaultValue: PaymentSecrets.secretKey,
  );
}

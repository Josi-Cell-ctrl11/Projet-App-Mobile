/// Constantes métier OZELSERVICES (règles demandées par le produit).
abstract final class AppConstants {
  /// Commande minimum OzelFoods (FCFA).
  static const double minFoodOrderFcfa = 1500;

  /// Délai d’acceptation restaurant avant annulation auto (minutes).
  static const int restaurantAcceptanceMinutes = 3;

  /// Seuil de retard livreur pour remboursement en points (minutes).
  static const int lateDeliveryMinutes = 15;

  /// Pourcentage du panier remboursé en points Ozel si retard > seuil.
  static const double lateDeliveryRefundPercent = 0.10;

  /// 1 FCFA dépensé = 1 point Ozel (arrondi sur total payé).
  static int fcfaToPoints(double fcfa) => fcfa.floor();

  /// Clé FedaPay publique (placeholder — à remplacer par ta clé réelle).
  static const String fedapayPublicKeyPlaceholder = "pk_live_OR_test_FEDAPAY";

  /// Clé Google Maps (AndroidManifest) — rappel pour l’équipe.
  static const String mapsKeyReminder = "YOUR_GOOGLE_MAPS_KEY";
}

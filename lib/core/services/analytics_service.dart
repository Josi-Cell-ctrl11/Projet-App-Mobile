import "package:firebase_analytics/firebase_analytics.dart";

/// Service Analytics OZELSERVICES.
/// Centralise tous les événements trackés dans l'app.
class AnalyticsService {
  AnalyticsService._();
  static final instance = AnalyticsService._();

  final _analytics = FirebaseAnalytics.instance;

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> logLogin() =>
      _analytics.logLogin(loginMethod: "phone_otp");

  Future<void> logSignUp() =>
      _analytics.logSignUp(signUpMethod: "phone_otp");

  // ── OzelFoods ─────────────────────────────────────────────────────────────

  Future<void> logViewRestaurant(String restaurantId, String name) =>
      _analytics.logViewItem(
        currency: "XOF",
        items: [
          AnalyticsEventItem(
            itemId: restaurantId,
            itemName: name,
            itemCategory: "restaurant",
          ),
        ],
      );

  Future<void> logAddToCart(String itemName, double price) =>
      _analytics.logAddToCart(
        value: price,
        currency: "XOF",
        items: [
          AnalyticsEventItem(
            itemId: itemName,
            itemName: itemName,
            itemCategory: "food",
            price: price,
            currency: "XOF",
          ),
        ],
      );

  Future<void> logOrderFood(double total) =>
      _analytics.logPurchase(
        transactionId: "food_${DateTime.now().millisecondsSinceEpoch}",
        value: total,
        currency: "XOF",
      );

  // ── Rapid Colis ───────────────────────────────────────────────────────────

  Future<void> logOrderColis(double price) =>
      _analytics.logPurchase(
        transactionId: "colis_${DateTime.now().millisecondsSinceEpoch}",
        value: price,
        currency: "XOF",
      );

  // ── Ozel Event ────────────────────────────────────────────────────────────

  Future<void> logDemandeEvent(String typeEvenement) =>
      _analytics.logEvent(
        name: "demande_event",
        parameters: {"type_evenement": typeEvenement},
      );

  // ── Ozel Tours ────────────────────────────────────────────────────────────

  Future<void> logViewCircuit(String circuitId, String nom) =>
      _analytics.logViewItem(
        currency: "XOF",
        items: [
          AnalyticsEventItem(
            itemId: circuitId,
            itemName: nom,
            itemCategory: "circuit",
          ),
        ],
      );

  Future<void> logReservationTour(String circuitNom, double montant) =>
      _analytics.logPurchase(
        transactionId: "tour_${DateTime.now().millisecondsSinceEpoch}",
        value: montant,
        currency: "XOF",
      );

  // ── Ozel Sécurités ────────────────────────────────────────────────────────

  Future<void> logDemandeSecurite(String typeService) =>
      _analytics.logEvent(
        name: "demande_securite",
        parameters: {"type_service": typeService},
      );

  // ── Ozel TIC ──────────────────────────────────────────────────────────────

  Future<void> logDemandeTic(String typeService) =>
      _analytics.logEvent(
        name: "demande_tic",
        parameters: {"type_service": typeService},
      );

  // ── Navigation écrans ─────────────────────────────────────────────────────

  Future<void> logScreenView(String screenName) =>
      _analytics.logScreenView(screenName: screenName);

  // ── Générique ─────────────────────────────────────────────────────────────

  Future<void> logEvent(String name,
          {Map<String, Object>? parameters}) =>
      _analytics.logEvent(name: name, parameters: parameters);

  /// Associe l'utilisateur connecté à ses événements Analytics.
  Future<void> setUserId(String uid) =>
      _analytics.setUserId(id: uid);
}

// Repository navigation — stub prêt pour l'intégration Google Maps
import 'dart:math';

/// Interface du repository de navigation GPS
abstract class INavigationRepository {
  /// Lance l'application de navigation externe (Google Maps / Waze) vers une adresse.
  Future<void> lancerNavigationExterne({
    required double latitude,
    required double longitude,
    required String libelle,
  });

  /// Calcule la distance en ligne droite entre deux points GPS (en km).
  double calculerDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  );
}

/// Implémentation mock du repository de navigation
class MockNavigationRepository implements INavigationRepository {
  @override
  Future<void> lancerNavigationExterne({
    required double latitude,
    required double longitude,
    required String libelle,
  }) async {
    // En production : url_launcher vers
    // google.navigation:q=lat,lng&mode=d  (Android)
    // maps://?daddr=lat,lng               (iOS)
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  double calculerDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    // Formule de Haversine simplifiée
    const r = 6371.0; // Rayon Terre en km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _toRad(double deg) => deg * pi / 180;
}

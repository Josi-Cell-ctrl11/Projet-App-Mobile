import "dart:math" as math;

/// Calcul tarifaire Rapid Colis (MVP) :
/// - Distance : 1000 FCFA pour moins de 3 km, puis +150 FCFA / km.
/// - Poids : +500 FCFA par kg au-delà de 5 kg.
abstract final class RapidColisPricing {
  static const double baseFcfa = 1000;
  static const double freeKm = 3;
  static const double perKmFcfa = 150;
  static const double perExtraKgFcfa = 500;
  static const double heavyThresholdKg = 5;

  /// Retourne le total estimé en FCFA.
  static double quote({required double distanceKm, required double weightKg}) {
    final dist = math.max(0, distanceKm);
    final extraKm = math.max(0, dist - freeKm);
    final distancePart = baseFcfa + extraKm * perKmFcfa;
    final extraWeight = math.max(0, weightKg - heavyThresholdKg);
    final weightPart = extraWeight * perExtraKgFcfa;
    return distancePart + weightPart;
  }
}

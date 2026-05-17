/// Expédition Rapid Colis (formulaire + suivi).
class ColisShipment {
  const ColisShipment({
    required this.id,
    required this.pointA,
    required this.pointB,
    required this.weightKg,
    required this.distanceKm,
    required this.priceFcfa,
    this.photoPath,
    this.driverLat,
    this.driverLng,
  });

  final String id;
  final String pointA;
  final String pointB;
  final double weightKg;
  final double distanceKm;
  final double priceFcfa;
  final String? photoPath;

  /// Position mock du livreur pour la carte de suivi.
  final double? driverLat;
  final double? driverLng;

  ColisShipment copyWith({
    double? driverLat,
    double? driverLng,
  }) =>
      ColisShipment(
        id: id,
        pointA: pointA,
        pointB: pointB,
        weightKg: weightKg,
        distanceKm: distanceKm,
        priceFcfa: priceFcfa,
        photoPath: photoPath,
        driverLat: driverLat ?? this.driverLat,
        driverLng: driverLng ?? this.driverLng,
      );
}

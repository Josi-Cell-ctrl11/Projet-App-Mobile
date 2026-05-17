import "package:ozelservices/features/rapid_colis/application/colis_draft_notifier.dart";

/// Expedition Rapid Colis (formulaire + suivi).
class ColisShipment {
  const ColisShipment({
    required this.id,
    required this.pointA,
    required this.pointB,
    required this.weightKg,
    required this.distanceKm,
    required this.priceFcfa,
    this.photoPath,
    this.payeur = PayeurColis.expediteur,
    this.nomDestinataire = "",
    this.telephoneDestinataire = "",
    this.mode = ModeColis.colis,
    this.driverLat,
    this.driverLng,
  });

  final String id;
  final String pointA;
  final String pointB;

  /// Poids confirme par le livreur apres pesee sur place.
  final double weightKg;

  final double distanceKm;
  final double priceFcfa;
  final String? photoPath;

  /// Qui paie les frais de livraison.
  final PayeurColis payeur;

  final String nomDestinataire;
  final String telephoneDestinataire;

  /// Mode : colis standard ou coursier universel.
  final ModeColis mode;

  /// Position mock du livreur pour la carte de suivi.
  final double? driverLat;
  final double? driverLng;

  ColisShipment copyWith({
    double? weightKg,
    double? priceFcfa,
    double? driverLat,
    double? driverLng,
  }) =>
      ColisShipment(
        id: id,
        pointA: pointA,
        pointB: pointB,
        weightKg: weightKg ?? this.weightKg,
        distanceKm: distanceKm,
        priceFcfa: priceFcfa ?? this.priceFcfa,
        photoPath: photoPath,
        payeur: payeur,
        nomDestinataire: nomDestinataire,
        telephoneDestinataire: telephoneDestinataire,
        mode: mode,
        driverLat: driverLat ?? this.driverLat,
        driverLng: driverLng ?? this.driverLng,
      );
}

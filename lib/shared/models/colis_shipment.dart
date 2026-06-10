/// Qui prend en charge les frais de livraison.
enum PayeurColis { expediteur, destinataire }

/// Mode d'envoi : colis standard ou coursier universel.
enum ModeColis { colis, coursier }

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
    this.destinatairePrenom = "",
    this.destinataireNom = "",
    this.destinataireTelephone = "",
    this.mode = ModeColis.colis,
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
  final PayeurColis payeur;
  final String destinatairePrenom;
  final String destinataireNom;
  final String destinataireTelephone;
  final ModeColis mode;
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
        destinatairePrenom: destinatairePrenom,
        destinataireNom: destinataireNom,
        destinataireTelephone: destinataireTelephone,
        mode: mode,
        driverLat: driverLat ?? this.driverLat,
        driverLng: driverLng ?? this.driverLng,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "pointA": pointA,
        "pointB": pointB,
        "weightKg": weightKg,
        "distanceKm": distanceKm,
        "priceFcfa": priceFcfa,
        "photoPath": photoPath,
        "payeur": payeur.name,
        "destinatairePrenom": destinatairePrenom,
        "destinataireNom": destinataireNom,
        "destinataireTelephone": destinataireTelephone,
        "mode": mode.name,
        "driverLat": driverLat,
        "driverLng": driverLng,
      };

  factory ColisShipment.fromJson(Map<String, dynamic> json) => ColisShipment(
        id: json["id"] as String? ?? "",
        pointA: json["pointA"] as String? ?? "",
        pointB: json["pointB"] as String? ?? "",
        weightKg: (json["weightKg"] as num?)?.toDouble() ?? 0,
        distanceKm: (json["distanceKm"] as num?)?.toDouble() ?? 0,
        priceFcfa: (json["priceFcfa"] as num?)?.toDouble() ?? 0,
        photoPath: json["photoPath"] as String?,
        payeur: PayeurColis.values.byName(
          json["payeur"] as String? ?? PayeurColis.expediteur.name,
        ),
        destinatairePrenom: json["destinatairePrenom"] as String? ?? "",
        destinataireNom: json["destinataireNom"] as String? ?? "",
        destinataireTelephone: json["destinataireTelephone"] as String? ?? "",
        mode: ModeColis.values.byName(
          json["mode"] as String? ?? ModeColis.colis.name,
        ),
        driverLat: (json["driverLat"] as num?)?.toDouble(),
        driverLng: (json["driverLng"] as num?)?.toDouble(),
      );
}

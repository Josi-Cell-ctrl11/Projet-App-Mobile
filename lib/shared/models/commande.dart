// Modèle Commande — représente une demande de livraison OZELSERVICES

/// Type de commande : repas ou colis
enum TypeCommande { ozelFoods, rapidColis }

/// Statut de progression d'une commande
enum StatutCommande {
  disponible,
  acceptee,
  auPickup,
  enRoute,
  livree,
  annulee,
}

/// Adresse géolocalisée
class Adresse {
  final String libelle;
  final double latitude;
  final double longitude;

  const Adresse({
    required this.libelle,
    required this.latitude,
    required this.longitude,
  });

  Adresse copyWith({
    String? libelle,
    double? latitude,
    double? longitude,
  }) {
    return Adresse(
      libelle: libelle ?? this.libelle,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'libelle': libelle,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Adresse.fromJson(Map<String, dynamic> json) {
    return Adresse(
      libelle: json['libelle'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  @override
  String toString() => 'Adresse($libelle, lat: $latitude, lng: $longitude)';
}

/// Commande de livraison assignable à un livreur
class Commande {
  final String id;
  final TypeCommande type;
  final String clientNom;

  /// Numéro de téléphone du client (peut être masqué partiellement)
  final String clientTelephone;
  final Adresse adressePickup;
  final Adresse adresseLivraison;

  /// Description des articles (OzelFoods) ou du colis (Rapid Colis)
  final String descriptionArticles;
  final double distanceKm;
  final int tempsEstimeMinutes;

  /// Montant brut de la livraison
  final double montantTotal;

  /// Part reversée au livreur (70% de montantTotal)
  final double partLivreur;
  final StatutCommande statut;

  /// Code OTP que le client doit fournir pour valider la livraison
  final String? otpCode;
  final DateTime createdAt;

  const Commande({
    required this.id,
    required this.type,
    required this.clientNom,
    required this.clientTelephone,
    required this.adressePickup,
    required this.adresseLivraison,
    required this.descriptionArticles,
    required this.distanceKm,
    required this.tempsEstimeMinutes,
    required this.montantTotal,
    required this.partLivreur,
    required this.statut,
    this.otpCode,
    required this.createdAt,
  });

  Commande copyWith({
    String? id,
    TypeCommande? type,
    String? clientNom,
    String? clientTelephone,
    Adresse? adressePickup,
    Adresse? adresseLivraison,
    String? descriptionArticles,
    double? distanceKm,
    int? tempsEstimeMinutes,
    double? montantTotal,
    double? partLivreur,
    StatutCommande? statut,
    String? otpCode,
    DateTime? createdAt,
  }) {
    return Commande(
      id: id ?? this.id,
      type: type ?? this.type,
      clientNom: clientNom ?? this.clientNom,
      clientTelephone: clientTelephone ?? this.clientTelephone,
      adressePickup: adressePickup ?? this.adressePickup,
      adresseLivraison: adresseLivraison ?? this.adresseLivraison,
      descriptionArticles: descriptionArticles ?? this.descriptionArticles,
      distanceKm: distanceKm ?? this.distanceKm,
      tempsEstimeMinutes: tempsEstimeMinutes ?? this.tempsEstimeMinutes,
      montantTotal: montantTotal ?? this.montantTotal,
      partLivreur: partLivreur ?? this.partLivreur,
      statut: statut ?? this.statut,
      otpCode: otpCode ?? this.otpCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'clientNom': clientNom,
      'clientTelephone': clientTelephone,
      'adressePickup': adressePickup.toJson(),
      'adresseLivraison': adresseLivraison.toJson(),
      'descriptionArticles': descriptionArticles,
      'distanceKm': distanceKm,
      'tempsEstimeMinutes': tempsEstimeMinutes,
      'montantTotal': montantTotal,
      'partLivreur': partLivreur,
      'statut': statut.name,
      'otpCode': otpCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'] as String,
      type: TypeCommande.values.firstWhere((e) => e.name == json['type']),
      clientNom: json['clientNom'] as String,
      clientTelephone: json['clientTelephone'] as String,
      adressePickup:
          Adresse.fromJson(json['adressePickup'] as Map<String, dynamic>),
      adresseLivraison:
          Adresse.fromJson(json['adresseLivraison'] as Map<String, dynamic>),
      descriptionArticles: json['descriptionArticles'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      tempsEstimeMinutes: json['tempsEstimeMinutes'] as int,
      montantTotal: (json['montantTotal'] as num).toDouble(),
      partLivreur: (json['partLivreur'] as num).toDouble(),
      statut:
          StatutCommande.values.firstWhere((e) => e.name == json['statut']),
      otpCode: json['otpCode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() =>
      'Commande(id: $id, type: $type, statut: $statut, partLivreur: $partLivreur)';
}

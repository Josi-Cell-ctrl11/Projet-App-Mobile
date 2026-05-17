// Modèle Livreur — représente un agent de livraison OZELSERVICES
import 'document.dart';

/// Type de véhicule utilisé par le livreur
enum TypeVehicule { moto, velo, voiture }

/// Représente un livreur enregistré sur la plateforme OZELSERVICES BENIN
class Livreur {
  final String id;
  final String nom;
  final String prenom;
  final String telephone;
  final String? photoUrl;
  final TypeVehicule typeVehicule;

  /// Note moyenne sur 5 étoiles
  final double note;

  /// Nombre total de livraisons effectuées
  final int totalLivraisons;

  /// Indique si le livreur est actuellement en ligne
  final bool estEnLigne;

  /// Documents officiels du livreur (CNI, Permis, Assurance)
  final List<Document> documents;

  /// Token JWT de session (null si non connecté)
  final String? token;

  const Livreur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    this.photoUrl,
    required this.typeVehicule,
    required this.note,
    required this.totalLivraisons,
    required this.estEnLigne,
    required this.documents,
    this.token,
  });

  /// Nom complet du livreur
  String get nomComplet => '$prenom $nom';

  Livreur copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? telephone,
    String? photoUrl,
    TypeVehicule? typeVehicule,
    double? note,
    int? totalLivraisons,
    bool? estEnLigne,
    List<Document>? documents,
    String? token,
  }) {
    return Livreur(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      photoUrl: photoUrl ?? this.photoUrl,
      typeVehicule: typeVehicule ?? this.typeVehicule,
      note: note ?? this.note,
      totalLivraisons: totalLivraisons ?? this.totalLivraisons,
      estEnLigne: estEnLigne ?? this.estEnLigne,
      documents: documents ?? this.documents,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'photoUrl': photoUrl,
      'typeVehicule': typeVehicule.name,
      'note': note,
      'totalLivraisons': totalLivraisons,
      'estEnLigne': estEnLigne,
      'documents': documents.map((d) => d.toJson()).toList(),
      'token': token,
    };
  }

  factory Livreur.fromJson(Map<String, dynamic> json) {
    return Livreur(
      id: json['id'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      telephone: json['telephone'] as String,
      photoUrl: json['photoUrl'] as String?,
      typeVehicule: TypeVehicule.values
          .firstWhere((e) => e.name == json['typeVehicule']),
      note: (json['note'] as num).toDouble(),
      totalLivraisons: json['totalLivraisons'] as int,
      estEnLigne: json['estEnLigne'] as bool,
      documents: (json['documents'] as List<dynamic>)
          .map((d) => Document.fromJson(d as Map<String, dynamic>))
          .toList(),
      token: json['token'] as String?,
    );
  }

  @override
  String toString() =>
      'Livreur(id: $id, nomComplet: $nomComplet, note: $note, estEnLigne: $estEnLigne)';
}

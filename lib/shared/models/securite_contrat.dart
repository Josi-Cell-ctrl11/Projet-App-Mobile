import "package:cloud_firestore/cloud_firestore.dart";

/// Contrat Ozel Sécurités.
enum TypeContrat { jardinage, vigile, nounou, entretien }
enum StatutContrat { actif, suspendu, termine }

class SecuriteContrat {
  const SecuriteContrat({
    required this.id,
    required this.type,
    required this.formule,
    required this.dateDebut,
    required this.dureeMois,
    required this.montant,
    required this.statut,
    required this.adresse,
    this.userId = "",
    this.prochainPassage,
  });

  final String id;
  final String userId;
  final TypeContrat type;
  final String formule;
  final DateTime dateDebut;
  final int dureeMois;
  final double montant;
  final StatutContrat statut;
  final String adresse;
  final DateTime? prochainPassage;

  String get typeLabel => switch (type) {
        TypeContrat.jardinage => "Jardinage",
        TypeContrat.vigile => "Vigile",
        TypeContrat.nounou => "Nounou",
        TypeContrat.entretien => "Entretien",
      };

  String get statutLabel => switch (statut) {
        StatutContrat.actif => "Actif",
        StatutContrat.suspendu => "Suspendu",
        StatutContrat.termine => "Terminé",
      };

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "type": type.name,
        "formule": formule,
        "dateDebut": Timestamp.fromDate(dateDebut),
        "dureeMois": dureeMois,
        "montant": montant,
        "statut": statut.name,
        "adresse": adresse,
        "prochainPassage":
            prochainPassage != null ? Timestamp.fromDate(prochainPassage!) : null,
      };

  factory SecuriteContrat.fromJson(Map<String, dynamic> json) =>
      SecuriteContrat(
        id: json["id"] as String? ?? "",
        userId: json["userId"] as String? ?? "",
        type: TypeContrat.values.byName(json["type"] as String? ?? "vigile"),
        formule: json["formule"] as String? ?? "",
        dateDebut: json["dateDebut"] is Timestamp
            ? (json["dateDebut"] as Timestamp).toDate()
            : DateTime.now(),
        dureeMois: json["dureeMois"] as int? ?? 1,
        montant: (json["montant"] as num?)?.toDouble() ?? 0,
        statut: StatutContrat.values
            .byName(json["statut"] as String? ?? "actif"),
        adresse: json["adresse"] as String? ?? "",
        prochainPassage: json["prochainPassage"] is Timestamp
            ? (json["prochainPassage"] as Timestamp).toDate()
            : null,
      );
}

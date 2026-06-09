import "package:cloud_firestore/cloud_firestore.dart";

/// Ticket OzelTic.
enum StatutTicket { enAttente, assigne, enCours, resolu }
enum ModeIntervention { domicile, distance }

class TicTicket {
  const TicTicket({
    required this.id,
    required this.type,
    required this.mode,
    required this.description,
    required this.montant,
    required this.statut,
    required this.createdAt,
    this.userId = "",
    this.adresse,
    this.technicien,
  });

  final String id;
  final String userId;
  final String type;
  final ModeIntervention mode;
  final String description;
  final double montant;
  final StatutTicket statut;
  final DateTime createdAt;
  final String? adresse;
  final String? technicien;

  String get statutLabel => switch (statut) {
        StatutTicket.enAttente => "En attente de technicien",
        StatutTicket.assigne => "Technicien assigné",
        StatutTicket.enCours => "En cours",
        StatutTicket.resolu => "Résolu",
      };

  String get modeLabel => switch (mode) {
        ModeIntervention.domicile => "À domicile",
        ModeIntervention.distance => "À distance",
      };

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "type": type,
        "mode": mode.name,
        "description": description,
        "montant": montant,
        "statut": statut.name,
        "createdAt": Timestamp.fromDate(createdAt),
        "adresse": adresse,
        "technicien": technicien,
      };

  factory TicTicket.fromJson(Map<String, dynamic> json) => TicTicket(
        id: json["id"] as String? ?? "",
        userId: json["userId"] as String? ?? "",
        type: json["type"] as String? ?? "",
        mode: ModeIntervention.values.byName(
          json["mode"] as String? ?? "domicile",
        ),
        description: json["description"] as String? ?? "",
        montant: (json["montant"] as num?)?.toDouble() ?? 0,
        statut: StatutTicket.values.byName(
          json["statut"] as String? ?? "enAttente",
        ),
        createdAt: json["createdAt"] is Timestamp
            ? (json["createdAt"] as Timestamp).toDate()
            : DateTime.now(),
        adresse: json["adresse"] as String?,
        technicien: json["technicien"] as String?,
      );
}

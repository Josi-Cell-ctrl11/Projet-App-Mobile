/// Modele intervention d'urgence Ozel Securites.
enum StatutIntervention { enCours, resolue, annulee }

class InterventionUrgence {
  const InterventionUrgence({
    required this.id,
    required this.type,
    required this.adresse,
    required this.dateHeure,
    required this.statut,
    required this.montant,
  });

  final String id;
  final String type;
  final String adresse;
  final DateTime dateHeure;
  final StatutIntervention statut;
  final double montant;

  String get statutLabel => switch (statut) {
        StatutIntervention.enCours => "En cours",
        StatutIntervention.resolue => "Resolue",
        StatutIntervention.annulee => "Annulee",
      };

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "adresse": adresse,
        "dateHeure": dateHeure.toIso8601String(),
        "statut": statut.name,
        "montant": montant,
      };

  factory InterventionUrgence.fromJson(Map<String, dynamic> json) =>
      InterventionUrgence(
        id: json["id"] as String? ?? "",
        type: json["type"] as String? ?? "",
        adresse: json["adresse"] as String? ?? "",
        dateHeure: DateTime.tryParse(json["dateHeure"] as String? ?? "") ??
            DateTime.now(),
        statut: StatutIntervention.values.byName(
          json["statut"] as String? ?? StatutIntervention.enCours.name,
        ),
        montant: (json["montant"] as num?)?.toDouble() ?? 0,
      );
}

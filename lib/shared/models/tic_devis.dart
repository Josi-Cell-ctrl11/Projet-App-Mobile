/// Modele devis projet OzelTic.
enum StatutDevis { enAttente, enEtude, accepte, refuse }

class TicDevis {
  const TicDevis({
    required this.id,
    required this.typeProjet,
    required this.description,
    required this.budget,
    required this.delai,
    required this.statut,
    required this.createdAt,
  });

  final String id;
  final String typeProjet;
  final String description;
  final double budget;
  final String delai;
  final StatutDevis statut;
  final DateTime createdAt;

  String get statutLabel => switch (statut) {
        StatutDevis.enAttente => "En attente",
        StatutDevis.enEtude => "En etude",
        StatutDevis.accepte => "Accepte",
        StatutDevis.refuse => "Refuse",
      };

  Map<String, dynamic> toJson() => {
        "id": id,
        "typeProjet": typeProjet,
        "description": description,
        "budget": budget,
        "delai": delai,
        "statut": statut.name,
        "createdAt": createdAt.toIso8601String(),
      };

  factory TicDevis.fromJson(Map<String, dynamic> json) => TicDevis(
        id: json["id"] as String? ?? "",
        typeProjet: json["typeProjet"] as String? ?? "",
        description: json["description"] as String? ?? "",
        budget: (json["budget"] as num?)?.toDouble() ?? 0,
        delai: json["delai"] as String? ?? "",
        statut: StatutDevis.values.byName(
          json["statut"] as String? ?? StatutDevis.enAttente.name,
        ),
        createdAt: DateTime.tryParse(json["createdAt"] as String? ?? "") ??
            DateTime.now(),
      );
}

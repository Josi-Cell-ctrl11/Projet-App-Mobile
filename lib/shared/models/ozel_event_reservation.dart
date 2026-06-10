/// Modele reservation Ozel Event — evenementiel au Benin.
enum TypeEvenement { mariage, anniversaire, conference }

enum StatutReservation { enAttente, confirme, enCours, termine }

class OzelEventReservation {
  const OzelEventReservation({
    required this.id,
    required this.type,
    required this.dateEvenement,
    required this.lieu,
    required this.nbInvites,
    required this.servicesChoisis,
    required this.montantTotal,
    required this.acompte,
    required this.soldeRestant,
    required this.statut,
    required this.chefProjetAssigne,
    required this.createdAt,
  });

  final String id;
  final TypeEvenement type;
  final DateTime dateEvenement;
  final String lieu;
  final int nbInvites;
  final List<String> servicesChoisis;
  final double montantTotal;
  final double acompte;
  final double soldeRestant;
  final StatutReservation statut;
  final bool chefProjetAssigne;
  final DateTime createdAt;

  String get typeLabel => switch (type) {
        TypeEvenement.mariage => "Mariage",
        TypeEvenement.anniversaire => "Anniversaire / Bapteme",
        TypeEvenement.conference => "Conference / Seminaire",
      };

  String get statutLabel => switch (statut) {
        StatutReservation.enAttente => "En attente",
        StatutReservation.confirme => "Confirme",
        StatutReservation.enCours => "En cours",
        StatutReservation.termine => "Termine",
      };

  String get typeEmoji => switch (type) {
        TypeEvenement.mariage => "🎊",
        TypeEvenement.anniversaire => "🎂",
        TypeEvenement.conference => "💼",
      };

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type.name,
        "dateEvenement": dateEvenement.toIso8601String(),
        "lieu": lieu,
        "nbInvites": nbInvites,
        "servicesChoisis": servicesChoisis,
        "montantTotal": montantTotal,
        "acompte": acompte,
        "soldeRestant": soldeRestant,
        "statut": statut.name,
        "chefProjetAssigne": chefProjetAssigne,
        "createdAt": createdAt.toIso8601String(),
      };

  factory OzelEventReservation.fromJson(Map<String, dynamic> json) =>
      OzelEventReservation(
        id: json["id"] as String? ?? "",
        type: TypeEvenement.values.byName(
          json["type"] as String? ?? TypeEvenement.mariage.name,
        ),
        dateEvenement:
            DateTime.tryParse(json["dateEvenement"] as String? ?? "") ??
                DateTime.now(),
        lieu: json["lieu"] as String? ?? "",
        nbInvites: json["nbInvites"] as int? ?? 0,
        servicesChoisis:
            List<String>.from(json["servicesChoisis"] as List? ?? []),
        montantTotal: (json["montantTotal"] as num?)?.toDouble() ?? 0,
        acompte: (json["acompte"] as num?)?.toDouble() ?? 0,
        soldeRestant: (json["soldeRestant"] as num?)?.toDouble() ?? 0,
        statut: StatutReservation.values.byName(
          json["statut"] as String? ?? StatutReservation.enAttente.name,
        ),
        chefProjetAssigne: json["chefProjetAssigne"] as bool? ?? false,
        createdAt: DateTime.tryParse(json["createdAt"] as String? ?? "") ??
            DateTime.now(),
      );
}

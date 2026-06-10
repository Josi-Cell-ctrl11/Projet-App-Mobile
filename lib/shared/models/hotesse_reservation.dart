/// Modele reservation Ozel Hotesses.
enum StatutHotesseReservation { enAttente, confirmee, enCours, terminee }

class HotesseReservation {
  const HotesseReservation({
    required this.id,
    required this.hotesseId,
    required this.hotessePrenom,
    required this.dateDebut,
    required this.dureeHeures,
    required this.tarif,
    required this.statut,
    required this.typeEvenement,
  });

  final String id;
  final String hotesseId;
  final String hotessePrenom;
  final DateTime dateDebut;
  final int dureeHeures;
  final double tarif;
  final StatutHotesseReservation statut;
  final String typeEvenement;

  String get statutLabel => switch (statut) {
        StatutHotesseReservation.enAttente => "En attente",
        StatutHotesseReservation.confirmee => "Confirmee",
        StatutHotesseReservation.enCours => "En cours",
        StatutHotesseReservation.terminee => "Terminee",
      };

  Map<String, dynamic> toJson() => {
        "id": id,
        "hotesseId": hotesseId,
        "hotessePrenom": hotessePrenom,
        "dateDebut": dateDebut.toIso8601String(),
        "dureeHeures": dureeHeures,
        "tarif": tarif,
        "statut": statut.name,
        "typeEvenement": typeEvenement,
      };

  factory HotesseReservation.fromJson(Map<String, dynamic> json) =>
      HotesseReservation(
        id: json["id"] as String? ?? "",
        hotesseId: json["hotesseId"] as String? ?? "",
        hotessePrenom: json["hotessePrenom"] as String? ?? "",
        dateDebut: DateTime.tryParse(json["dateDebut"] as String? ?? "") ??
            DateTime.now(),
        dureeHeures: json["dureeHeures"] as int? ?? 0,
        tarif: (json["tarif"] as num?)?.toDouble() ?? 0,
        statut: StatutHotesseReservation.values.byName(
          json["statut"] as String? ?? StatutHotesseReservation.enAttente.name,
        ),
        typeEvenement: json["typeEvenement"] as String? ?? "",
      );
}

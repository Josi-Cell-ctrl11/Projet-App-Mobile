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

  /// Duree en heures (minimum 4h)
  final int dureeHeures;

  /// Tarif total calcule
  final double tarif;
  final StatutHotesseReservation statut;
  final String typeEvenement;

  String get statutLabel => switch (statut) {
        StatutHotesseReservation.enAttente => 'En attente',
        StatutHotesseReservation.confirmee => 'Confirmee',
        StatutHotesseReservation.enCours => 'En cours',
        StatutHotesseReservation.terminee => 'Terminee',
      };
}

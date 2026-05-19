/// Modele reservation Ozel Tours.
enum StatutTourReservation { confirmee, enCours, terminee, annulee }

class TourReservation {
  const TourReservation({
    required this.id,
    required this.circuitId,
    required this.circuitNom,
    required this.destination,
    required this.dateDepart,
    required this.nbPersonnes,
    required this.montant,
    required this.qrCode,
    required this.statut,
    required this.guide,
  });

  final String id;
  final String circuitId;
  final String circuitNom;
  final String destination;
  final DateTime dateDepart;
  final int nbPersonnes;
  final double montant;

  /// QR code mock (identifiant de reservation)
  final String qrCode;
  final StatutTourReservation statut;
  final String guide;

  String get statutLabel => switch (statut) {
        StatutTourReservation.confirmee => 'Confirmee',
        StatutTourReservation.enCours => 'En cours',
        StatutTourReservation.terminee => 'Terminee',
        StatutTourReservation.annulee => 'Annulee',
      };
}

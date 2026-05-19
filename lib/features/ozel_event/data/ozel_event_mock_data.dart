import "package:ozelservices/shared/models/ozel_event_reservation.dart";

/// Données mock pour Ozel Event
class OzelEventMockData {
  static const List<OzelEventReservation> reservations = [
    OzelEventReservation(
      id: "OE-001",
      type: "Mariage",
      dateEvenement: DateTime(2026, 6, 15),
      lieu: "Salle des fêtes, Cotonou",
      nbInvites: 150,
      servicesChoisis: ["Sono", "Traiteur", "Déco", "Chef Projet"],
      montantTotal: 1275000,
      acompte: 637500,
      soldeRestant: 637500,
      statut: EventReservationStatut.confirme,
      chefProjetAssigne: "Kofi A.",
      createdAt: DateTime(2026, 5, 10),
    ),
    OzelEventReservation(
      id: "OE-002",
      type: "Conférence",
      dateEvenement: DateTime(2026, 7, 20),
      lieu: "Palais des Congrès, Cotonou",
      nbInvites: 80,
      servicesChoisis: ["Sono", "Déco"],
      montantTotal: 360000,
      acompte: 180000,
      soldeRestant: 180000,
      statut: EventReservationStatut.enAttente,
      createdAt: DateTime(2026, 5, 18),
    ),
    OzelEventReservation(
      id: "OE-003",
      type: "Anniversaire",
      dateEvenement: DateTime(2026, 4, 25),
      lieu: "Domicile, Porto-Novo",
      nbInvites: 30,
      servicesChoisis: ["Sono", "Traiteur"],
      montantTotal: 195000,
      acompte: 97500,
      soldeRestant: 0,
      statut: EventReservationStatut.termine,
      createdAt: DateTime(2026, 4, 10),
    ),
  ];

  static const List<String> eventTypes = [
    "Mariage",
    "Anniversaire / Baptême",
    "Conférence / Séminaire",
  ];

  static const Map<String, int> servicePrices = {
    "Sono": 1000,
    "Traiteur": 3500,
    "Décoration": 2000,
  };
}

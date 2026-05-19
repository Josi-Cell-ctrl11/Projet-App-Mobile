import "package:ozelservices/shared/models/hotesse_model.dart";
import "package:ozelservices/shared/models/hotesse_reservation.dart";

/// Données mock pour Ozel Hôtesses
class OzelHotessesMockData {
  static const List<HotesseModel> hotesses = [
    HotesseModel(
      id: "H001",
      prenom: "Aminata",
      taille: "1m68",
      langues: ["FR", "EN"],
      experience: 3,
      note: 4.8,
      tarif: 15000,
      tenues: ["formelle", "traditionnelle"],
      photoUrl: null, // Photo floutée
    ),
    HotesseModel(
      id: "H002",
      prenom: "Chantal",
      taille: "1m72",
      langues: ["FR"],
      experience: 5,
      note: 4.9,
      tarif: 15000,
      tenues: ["formelle"],
      photoUrl: null,
    ),
    HotesseModel(
      id: "H003",
      prenom: "Fatou",
      taille: "1m70",
      langues: ["FR", "EN"],
      experience: 2,
      note: 4.5,
      tarif: 15000,
      tenues: ["formelle", "traditionnelle"],
      photoUrl: null,
    ),
    HotesseModel(
      id: "H004",
      prenom: "Grace",
      taille: "1m65",
      langues: ["FR"],
      experience: 4,
      note: 4.7,
      tarif: 15000,
      tenues: ["formelle"],
      photoUrl: null,
    ),
    HotesseModel(
      id: "H005",
      prenom: "Sarah",
      taille: "1m74",
      langues: ["FR", "EN"],
      experience: 6,
      note: 4.9,
      tarif: 15000,
      tenues: ["formelle", "traditionnelle"],
      photoUrl: null,
    ),
  ];

  static const List<HotesseReservation> reservations = [
    HotesseReservation(
      id: "HR-001",
      hotesseId: "H001",
      hotessePrenom: "Aminata",
      dateDebut: DateTime(2026, 6, 10, 14, 0),
      dureeHeures: 8,
      tarif: 15000,
      statut: HotesseReservationStatut.confirme,
      createdAt: DateTime(2026, 5, 15),
      typeEvenement: "Conférence",
      tenueSouhaitee: "formelle",
      langueRequise: "FR",
      nbInvites: 60,
    ),
    HotesseReservation(
      id: "HR-002",
      hotesseId: "H003",
      hotessePrenom: "Fatou",
      dateDebut: DateTime(2026, 5, 28, 18, 0),
      dureeHeures: 6,
      tarif: 15000,
      statut: HotesseReservationStatut.enCours,
      createdAt: DateTime(2026, 5, 20),
      typeEvenement: "Mariage",
      tenueSouhaitee: "traditionnelle",
      langueRequise: "FR",
      nbInvites: 120,
    ),
  ];

  static const List<String> tenueOptions = [
    "formelle",
    "traditionnelle",
    "cocktail",
  ];

  static const List<String> langueOptions = ["FR", "EN"];
}

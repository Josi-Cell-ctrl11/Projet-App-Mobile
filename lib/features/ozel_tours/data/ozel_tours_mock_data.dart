import "package:ozelservices/shared/models/circuit_model.dart";
import "package:ozelservices/shared/models/tour_reservation.dart";

/// Données mock pour Ozel Tours
class OzelToursMockData {
  static const List<CircuitModel> circuits = [
    CircuitModel(
      id: "C001",
      nom: "Village lacustre de Ganvié",
      destination: "Ganvié",
      dureeJours: 1,
      prix: 25000,
      guide: "Koffi A.",
      note: 4.8,
      description: "Découvrez la Venise de l'Afrique. Balade en pirogue, visite des maisons sur pilotis, rencontre avec les habitants.",
      imageUrl: null,
      chauffeurInclus: true,
      assuranceIncluse: false,
    ),
    CircuitModel(
      id: "C002",
      nom: "Route des Esclaves - Ouidah",
      destination: "Ouidah",
      dureeJours: 1,
      prix: 20000,
      guide: "Adjoua M.",
      note: 4.9,
      description: "Plongez dans l'histoire du Bénin. Visite de la Route des Esclaves, musée, forêt sacrée, temple des pythons.",
      imageUrl: null,
      chauffeurInclus: true,
      assuranceIncluse: false,
    ),
    CircuitModel(
      id: "C003",
      nom: "Safari Pendjari",
      destination: "Pendjari",
      dureeJours: 3,
      prix: 150000,
      guide: "Emmanuel K.",
      note: 4.9,
      description: "Safari inoubliable dans le parc national de Pendjari. Observation des éléphants, lions, buffles. Hébergement inclus.",
      imageUrl: null,
      chauffeurInclus: true,
      assuranceIncluse: true,
    ),
    CircuitModel(
      id: "C004",
      nom: "Découverte de Cotonou",
      destination: "Cotonou",
      dureeJours: 1,
      prix: 15000,
      guide: "Yvette D.",
      note: 4.6,
      description: "Tour complet de la capitale économique. Marché Dantokpa, plage de Fidjrossè, quartier des artisans.",
      imageUrl: null,
      chauffeurInclus: false,
      assuranceIncluse: false,
    ),
  ];

  static const List<TourReservation> reservations = [
    TourReservation(
      id: "TR-001",
      circuitId: "C001",
      circuitNom: "Village lacustre de Ganvié",
      dateDepart: DateTime(2026, 6, 5),
      nbPersonnes: 4,
      montant: 100000,
      qrCode: "QR-GANVIE-001",
      statut: TourReservationStatut.confirme,
      createdAt: DateTime(2026, 5, 10),
      guideAssigne: "Koffi A.",
      chauffeurInclus: true,
    ),
  ];

  static const List<String> destinations = ["Ganvié", "Ouidah", "Pendjari", "Cotonou", "Abomey", "Grand-Popo"];
}

import "package:cloud_firestore/cloud_firestore.dart";

/// Réservation Ozel Tours.
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
    this.userId = "",
  });

  final String id;
  final String userId;
  final String circuitId;
  final String circuitNom;
  final String destination;
  final DateTime dateDepart;
  final int nbPersonnes;
  final double montant;
  final String qrCode;
  final StatutTourReservation statut;
  final String guide;

  String get statutLabel => switch (statut) {
        StatutTourReservation.confirmee => "Confirmée",
        StatutTourReservation.enCours => "En cours",
        StatutTourReservation.terminee => "Terminée",
        StatutTourReservation.annulee => "Annulée",
      };

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "circuitId": circuitId,
        "circuitNom": circuitNom,
        "destination": destination,
        "dateDepart": Timestamp.fromDate(dateDepart),
        "nbPersonnes": nbPersonnes,
        "montant": montant,
        "qrCode": qrCode,
        "statut": statut.name,
        "guide": guide,
        "createdAt": Timestamp.fromDate(DateTime.now()),
      };

  factory TourReservation.fromJson(Map<String, dynamic> json) =>
      TourReservation(
        id: json["id"] as String? ?? "",
        userId: json["userId"] as String? ?? "",
        circuitId: json["circuitId"] as String? ?? "",
        circuitNom: json["circuitNom"] as String? ?? "",
        destination: json["destination"] as String? ?? "",
        dateDepart: json["dateDepart"] is Timestamp
            ? (json["dateDepart"] as Timestamp).toDate()
            : DateTime.now(),
        nbPersonnes: json["nbPersonnes"] as int? ?? 1,
        montant: (json["montant"] as num?)?.toDouble() ?? 0,
        qrCode: json["qrCode"] as String? ?? "",
        statut: StatutTourReservation.values.byName(
          json["statut"] as String? ?? "confirmee",
        ),
        guide: json["guide"] as String? ?? "",
      );
}

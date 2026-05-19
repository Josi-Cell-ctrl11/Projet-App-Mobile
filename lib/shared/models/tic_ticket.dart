/// Modele ticket OzelTic.
enum StatutTicket { enAttente, assigne, enCours, resolu }
enum ModeIntervention { domicile, distance }

class TicTicket {
  const TicTicket({
    required this.id,
    required this.type,
    required this.mode,
    required this.description,
    required this.montant,
    required this.statut,
    required this.createdAt,
    this.adresse,
    this.technicien,
  });

  final String id;
  final String type;
  final ModeIntervention mode;
  final String description;
  final double montant;
  final StatutTicket statut;
  final DateTime createdAt;
  final String? adresse;
  final String? technicien;

  String get statutLabel => switch (statut) {
        StatutTicket.enAttente => 'En attente de technicien',
        StatutTicket.assigne => 'Technicien assigne',
        StatutTicket.enCours => 'En cours',
        StatutTicket.resolu => 'Resolu',
      };

  String get modeLabel => switch (mode) {
        ModeIntervention.domicile => 'A domicile',
        ModeIntervention.distance => 'A distance',
      };
}

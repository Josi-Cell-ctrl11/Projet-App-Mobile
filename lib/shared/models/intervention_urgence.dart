/// Modele intervention d'urgence Ozel Securites.
enum StatutIntervention { enCours, resolue, annulee }

class InterventionUrgence {
  const InterventionUrgence({
    required this.id,
    required this.type,
    required this.adresse,
    required this.dateHeure,
    required this.statut,
    required this.montant,
  });

  final String id;
  final String type;
  final String adresse;
  final DateTime dateHeure;
  final StatutIntervention statut;
  final double montant;

  String get statutLabel => switch (statut) {
        StatutIntervention.enCours => 'En cours',
        StatutIntervention.resolue => 'Resolue',
        StatutIntervention.annulee => 'Annulee',
      };
}

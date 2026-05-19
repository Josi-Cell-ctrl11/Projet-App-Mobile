/// Modele contrat Ozel Securites.
enum TypeContrat { jardinage, vigile }
enum StatutContrat { actif, suspendu, termine }

class SecuriteContrat {
  const SecuriteContrat({
    required this.id,
    required this.type,
    required this.formule,
    required this.dateDebut,
    required this.dureeMois,
    required this.montant,
    required this.statut,
    required this.adresse,
    this.prochainPassage,
  });

  final String id;
  final TypeContrat type;
  final String formule;
  final DateTime dateDebut;
  final int dureeMois;
  final double montant;
  final StatutContrat statut;
  final String adresse;
  final DateTime? prochainPassage;

  String get typeLabel => switch (type) {
        TypeContrat.jardinage => 'Jardinage',
        TypeContrat.vigile => 'Vigile',
      };

  String get statutLabel => switch (statut) {
        StatutContrat.actif => 'Actif',
        StatutContrat.suspendu => 'Suspendu',
        StatutContrat.termine => 'Termine',
      };
}

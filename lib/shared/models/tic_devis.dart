/// Modele devis projet OzelTic.
enum StatutDevis { enAttente, enEtude, accepte, refuse }

class TicDevis {
  const TicDevis({
    required this.id,
    required this.typeProjet,
    required this.description,
    required this.budget,
    required this.delai,
    required this.statut,
    required this.createdAt,
  });

  final String id;
  final String typeProjet;
  final String description;
  final double budget;
  final String delai;
  final StatutDevis statut;
  final DateTime createdAt;

  String get statutLabel => switch (statut) {
        StatutDevis.enAttente => 'En attente',
        StatutDevis.enEtude => 'En etude',
        StatutDevis.accepte => 'Accepte',
        StatutDevis.refuse => 'Refuse',
      };
}

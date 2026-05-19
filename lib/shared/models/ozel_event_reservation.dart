/// Modele reservation Ozel Event — evenementiel au Benin.

enum TypeEvenement { mariage, anniversaire, conference }

enum StatutReservation { enAttente, confirme, enCours, termine }

/// Regles metier :
/// - Sono : 1 000 FCFA/pers, Traiteur : 3 500 FCFA/pers, Deco : 2 000 FCFA/pers
/// - Acompte 50% obligatoire. Commission OZEL 20%.
/// - Chef projet auto si >100 invites.
class OzelEventReservation {
  const OzelEventReservation({
    required this.id,
    required this.type,
    required this.dateEvenement,
    required this.lieu,
    required this.nbInvites,
    required this.servicesChoisis,
    required this.montantTotal,
    required this.acompte,
    required this.soldeRestant,
    required this.statut,
    required this.chefProjetAssigne,
    required this.createdAt,
  });

  final String id;
  final TypeEvenement type;
  final DateTime dateEvenement;
  final String lieu;
  final int nbInvites;
  final List<String> servicesChoisis;
  final double montantTotal;
  final double acompte;
  final double soldeRestant;
  final StatutReservation statut;
  final bool chefProjetAssigne;
  final DateTime createdAt;

  String get typeLabel => switch (type) {
        TypeEvenement.mariage => 'Mariage',
        TypeEvenement.anniversaire => 'Anniversaire / Bapteme',
        TypeEvenement.conference => 'Conference / Seminaire',
      };

  String get statutLabel => switch (statut) {
        StatutReservation.enAttente => 'En attente',
        StatutReservation.confirme => 'Confirme',
        StatutReservation.enCours => 'En cours',
        StatutReservation.termine => 'Termine',
      };

  String get typeEmoji => switch (type) {
        TypeEvenement.mariage => '🎊',
        TypeEvenement.anniversaire => '🎂',
        TypeEvenement.conference => '💼',
      };
}

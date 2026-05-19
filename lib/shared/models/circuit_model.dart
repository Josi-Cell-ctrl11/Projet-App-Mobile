/// Modele circuit Ozel Tours.
class CircuitModel {
  const CircuitModel({
    required this.id,
    required this.nom,
    required this.destination,
    required this.dureeJours,
    required this.prix,
    required this.guide,
    required this.note,
    required this.description,
    required this.emoji,
    required this.programme,
    this.chauffeurInclus = true,
  });

  final String id;
  final String nom;
  final String destination;

  /// Duree en jours
  final int dureeJours;

  /// Prix TTC par personne (commission 12% incluse)
  final double prix;

  /// Nom du guide certifie
  final String guide;
  final double note;
  final String description;

  /// Emoji representant la destination
  final String emoji;

  /// Programme jour par jour
  final List<String> programme;

  final bool chauffeurInclus;

  /// Assurance incluse si >1 jour
  bool get assuranceIncluse => dureeJours > 1;

  /// Nombre d'avis mock
  int get nbAvis => (note * 10).round();
}

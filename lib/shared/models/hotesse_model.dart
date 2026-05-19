/// Modele hotesse Ozel Hotesses.
class HotesseModel {
  const HotesseModel({
    required this.id,
    required this.prenom,
    required this.taille,
    required this.langues,
    required this.experience,
    required this.note,
    required this.tarif,
    required this.tenues,
  });

  final String id;
  final String prenom;

  /// Taille en cm (ex: "1m70")
  final String taille;

  /// Langues parlees (ex: ['FR', 'EN'])
  final List<String> langues;

  /// Annees d'experience
  final int experience;

  /// Note moyenne sur 5
  final double note;

  /// Tarif de base par jour (8h) en FCFA
  final double tarif;

  /// Tenues disponibles (ex: ['Formelle', 'Traditionnelle'])
  final List<String> tenues;

  /// Initiales pour l'avatar (photo floutee)
  String get initiales => prenom.substring(0, 1).toUpperCase();

  bool get parleAnglais => langues.contains('EN');
}

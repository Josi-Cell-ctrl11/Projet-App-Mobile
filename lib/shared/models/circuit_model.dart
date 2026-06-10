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
  final int dureeJours;
  final double prix;
  final String guide;
  final double note;
  final String description;
  final String emoji;
  final List<String> programme;
  final bool chauffeurInclus;

  bool get assuranceIncluse => dureeJours > 1;
  int get nbAvis => (note * 10).round();

  Map<String, dynamic> toJson() => {
        "id": id,
        "nom": nom,
        "destination": destination,
        "dureeJours": dureeJours,
        "prix": prix,
        "guide": guide,
        "note": note,
        "description": description,
        "emoji": emoji,
        "programme": programme,
        "chauffeurInclus": chauffeurInclus,
      };

  factory CircuitModel.fromJson(Map<String, dynamic> json) => CircuitModel(
        id: json["id"] as String? ?? "",
        nom: json["nom"] as String? ?? "",
        destination: json["destination"] as String? ?? "",
        dureeJours: json["dureeJours"] as int? ?? 0,
        prix: (json["prix"] as num?)?.toDouble() ?? 0,
        guide: json["guide"] as String? ?? "",
        note: (json["note"] as num?)?.toDouble() ?? 0,
        description: json["description"] as String? ?? "",
        emoji: json["emoji"] as String? ?? "",
        programme: List<String>.from(json["programme"] as List? ?? []),
        chauffeurInclus: json["chauffeurInclus"] as bool? ?? true,
      );
}

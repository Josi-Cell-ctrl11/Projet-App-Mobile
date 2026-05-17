// Modèle Document — représente un document officiel du livreur

/// Types de documents requis pour un livreur
enum TypeDocument { cni, permis, assurance }

/// Statut de validation d'un document
enum StatutDocument { valide, enAttente, manquant }

/// Document officiel du livreur (CNI, Permis, Assurance)
class Document {
  final TypeDocument type;
  final StatutDocument statut;
  final DateTime? dateExpiration;

  const Document({
    required this.type,
    required this.statut,
    this.dateExpiration,
  });

  Document copyWith({
    TypeDocument? type,
    StatutDocument? statut,
    DateTime? dateExpiration,
  }) {
    return Document(
      type: type ?? this.type,
      statut: statut ?? this.statut,
      dateExpiration: dateExpiration ?? this.dateExpiration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'statut': statut.name,
      'dateExpiration': dateExpiration?.toIso8601String(),
    };
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      type: TypeDocument.values.firstWhere((e) => e.name == json['type']),
      statut:
          StatutDocument.values.firstWhere((e) => e.name == json['statut']),
      dateExpiration: json['dateExpiration'] != null
          ? DateTime.parse(json['dateExpiration'] as String)
          : null,
    );
  }

  @override
  String toString() =>
      'Document(type: $type, statut: $statut, dateExpiration: $dateExpiration)';
}

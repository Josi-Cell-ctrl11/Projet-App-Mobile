// Modèle Gain — représente les données financières du livreur
import 'commande.dart';

/// Statut de paiement d'une livraison
enum StatutPaiement { enAttente, credite }

/// Entrée dans l'historique des livraisons du livreur
class HistoriqueLivraison {
  final String commandeId;
  final TypeCommande type;
  final DateTime date;

  /// Montant gagné par le livreur (Part_Livreur = 70% du montant total)
  final double montantGagne;
  final StatutPaiement statutPaiement;

  const HistoriqueLivraison({
    required this.commandeId,
    required this.type,
    required this.date,
    required this.montantGagne,
    required this.statutPaiement,
  });

  HistoriqueLivraison copyWith({
    String? commandeId,
    TypeCommande? type,
    DateTime? date,
    double? montantGagne,
    StatutPaiement? statutPaiement,
  }) {
    return HistoriqueLivraison(
      commandeId: commandeId ?? this.commandeId,
      type: type ?? this.type,
      date: date ?? this.date,
      montantGagne: montantGagne ?? this.montantGagne,
      statutPaiement: statutPaiement ?? this.statutPaiement,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commandeId': commandeId,
      'type': type.name,
      'date': date.toIso8601String(),
      'montantGagne': montantGagne,
      'statutPaiement': statutPaiement.name,
    };
  }

  factory HistoriqueLivraison.fromJson(Map<String, dynamic> json) {
    return HistoriqueLivraison(
      commandeId: json['commandeId'] as String,
      type: TypeCommande.values.firstWhere((e) => e.name == json['type']),
      date: DateTime.parse(json['date'] as String),
      montantGagne: (json['montantGagne'] as num).toDouble(),
      statutPaiement: StatutPaiement.values
          .firstWhere((e) => e.name == json['statutPaiement']),
    );
  }

  @override
  String toString() =>
      'HistoriqueLivraison(commandeId: $commandeId, montantGagne: $montantGagne, statut: $statutPaiement)';
}

/// Données financières complètes du livreur
class GainsData {
  /// Solde disponible pour retrait (en FCFA)
  final double soldeDisponible;

  /// Gains de la journée en cours (en FCFA)
  final double gainsAujourdhui;

  /// Gains de la semaine en cours (en FCFA)
  final double gainsSemaine;

  /// Gains du mois en cours (en FCFA)
  final double gainsMois;

  /// Historique des livraisons effectuées
  final List<HistoriqueLivraison> historique;

  const GainsData({
    required this.soldeDisponible,
    required this.gainsAujourdhui,
    required this.gainsSemaine,
    required this.gainsMois,
    required this.historique,
  });

  GainsData copyWith({
    double? soldeDisponible,
    double? gainsAujourdhui,
    double? gainsSemaine,
    double? gainsMois,
    List<HistoriqueLivraison>? historique,
  }) {
    return GainsData(
      soldeDisponible: soldeDisponible ?? this.soldeDisponible,
      gainsAujourdhui: gainsAujourdhui ?? this.gainsAujourdhui,
      gainsSemaine: gainsSemaine ?? this.gainsSemaine,
      gainsMois: gainsMois ?? this.gainsMois,
      historique: historique ?? this.historique,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soldeDisponible': soldeDisponible,
      'gainsAujourdhui': gainsAujourdhui,
      'gainsSemaine': gainsSemaine,
      'gainsMois': gainsMois,
      'historique': historique.map((h) => h.toJson()).toList(),
    };
  }

  factory GainsData.fromJson(Map<String, dynamic> json) {
    return GainsData(
      soldeDisponible: (json['soldeDisponible'] as num).toDouble(),
      gainsAujourdhui: (json['gainsAujourdhui'] as num).toDouble(),
      gainsSemaine: (json['gainsSemaine'] as num).toDouble(),
      gainsMois: (json['gainsMois'] as num).toDouble(),
      historique: (json['historique'] as List<dynamic>)
          .map((h) => HistoriqueLivraison.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() =>
      'GainsData(solde: $soldeDisponible, aujourd\'hui: $gainsAujourdhui, semaine: $gainsSemaine, mois: $gainsMois)';
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/securite_contrat.dart';
import '../../../shared/models/intervention_urgence.dart';

/// Provider contrats securite
class SecuriteContratsNotifier extends Notifier<List<SecuriteContrat>> {
  @override
  List<SecuriteContrat> build() => _mockContrats;

  void addContrat(SecuriteContrat c) => state = [c, ...state];
}

final securiteContratsProvider =
    NotifierProvider<SecuriteContratsNotifier, List<SecuriteContrat>>(
  SecuriteContratsNotifier.new,
);

/// Provider interventions urgence
class InterventionsNotifier extends Notifier<List<InterventionUrgence>> {
  @override
  List<InterventionUrgence> build() => _mockInterventions;

  void addIntervention(InterventionUrgence i) => state = [i, ...state];
}

final interventionsProvider =
    NotifierProvider<InterventionsNotifier, List<InterventionUrgence>>(
  InterventionsNotifier.new,
);

/// Donnees mock
final _mockContrats = [
  SecuriteContrat(
    id: 'SC-001',
    type: TypeContrat.jardinage,
    formule: 'Abonnement mensuel',
    dateDebut: DateTime.now().subtract(const Duration(days: 30)),
    dureeMois: 3,
    montant: 25000,
    statut: StatutContrat.actif,
    adresse: 'Haie Vive, Cotonou',
    prochainPassage: DateTime.now().add(const Duration(days: 5)),
  ),
  SecuriteContrat(
    id: 'SC-002',
    type: TypeContrat.vigile,
    formule: '12h/nuit',
    dateDebut: DateTime.now().subtract(const Duration(days: 60)),
    dureeMois: 3,
    montant: 90000,
    statut: StatutContrat.actif,
    adresse: 'Akpakpa, Cotonou',
  ),
];

final _mockInterventions = [
  InterventionUrgence(
    id: 'INT-001',
    type: 'Intrusion',
    adresse: 'Cadjehoun, Cotonou',
    dateHeure: DateTime.now().subtract(const Duration(days: 15)),
    statut: StatutIntervention.resolue,
    montant: 15000,
  ),
];

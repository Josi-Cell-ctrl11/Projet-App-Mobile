import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/tic_ticket.dart';
import '../../../shared/models/tic_devis.dart';

/// Provider tickets OzelTic
class TicTicketsNotifier extends Notifier<List<TicTicket>> {
  @override
  List<TicTicket> build() => _mockTickets;

  void addTicket(TicTicket t) => state = [t, ...state];
}

final ticTicketsProvider =
    NotifierProvider<TicTicketsNotifier, List<TicTicket>>(
  TicTicketsNotifier.new,
);

/// Provider devis OzelTic
class TicDevisNotifier extends Notifier<List<TicDevis>> {
  @override
  List<TicDevis> build() => _mockDevis;

  void addDevis(TicDevis d) => state = [d, ...state];
}

final ticDevisProvider =
    NotifierProvider<TicDevisNotifier, List<TicDevis>>(
  TicDevisNotifier.new,
);

/// 3 tickets mock
final _mockTickets = [
  TicTicket(
    id: 'TIC-001',
    type: 'Virus/malware',
    mode: ModeIntervention.distance,
    description: 'Mon PC est tres lent depuis 2 jours, je pense a un virus.',
    montant: 3000,
    statut: StatutTicket.resolu,
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    technicien: 'Koffi Tech',
  ),
  TicTicket(
    id: 'TIC-002',
    type: 'Configuration reseau',
    mode: ModeIntervention.domicile,
    description: 'Ma connexion wifi ne fonctionne plus depuis hier.',
    montant: 5000,
    statut: StatutTicket.enCours,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    adresse: 'Haie Vive, Cotonou',
    technicien: 'Adjovi Dev',
  ),
  TicTicket(
    id: 'TIC-003',
    type: 'Installation logiciel',
    mode: ModeIntervention.distance,
    description: 'Besoin d\'installer Microsoft Office sur mon PC.',
    montant: 4000,
    statut: StatutTicket.enAttente,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
];

/// 1 devis mock
final _mockDevis = [
  TicDevis(
    id: 'DEV-001',
    typeProjet: 'Site web vitrine',
    description: 'Site vitrine pour mon restaurant a Cotonou.',
    budget: 200000,
    delai: '1 mois',
    statut: StatutDevis.enEtude,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];

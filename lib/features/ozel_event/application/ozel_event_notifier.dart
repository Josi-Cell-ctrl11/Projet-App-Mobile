import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/ozel_event_reservation.dart';

/// Tarifs Ozel Event (FCFA par personne)
abstract final class OzelEventTarifs {
  static const double sono = 1000;
  static const double traiteur = 3500;
  static const double deco = 2000;
  static const double commissionRate = 0.20; // 20%
  static const double acompteRate = 0.50; // 50%
}

/// Calcule le devis Ozel Event.
/// Chef projet inclus automatiquement si >100 invites.
double calculerDevisEvent({
  required int nbInvites,
  required bool sono,
  required bool traiteur,
  required bool deco,
}) {
  double sousTotal = 0;
  if (sono) sousTotal += OzelEventTarifs.sono * nbInvites;
  if (traiteur) sousTotal += OzelEventTarifs.traiteur * nbInvites;
  if (deco) sousTotal += OzelEventTarifs.deco * nbInvites;
  final commission = sousTotal * OzelEventTarifs.commissionRate;
  return sousTotal + commission;
}

/// Provider Riverpod — liste des reservations Ozel Event.
class OzelEventNotifier extends Notifier<List<OzelEventReservation>> {
  @override
  List<OzelEventReservation> build() => _mockReservations;

  void addReservation(OzelEventReservation r) {
    state = [r, ...state];
  }
}

final ozelEventProvider =
    NotifierProvider<OzelEventNotifier, List<OzelEventReservation>>(
  OzelEventNotifier.new,
);

/// Donnees mock — 3 reservations
final _mockReservations = [
  OzelEventReservation(
    id: 'OE-001',
    type: TypeEvenement.mariage,
    dateEvenement: DateTime.now().add(const Duration(days: 30)),
    lieu: 'Salle Prestige, Cotonou',
    nbInvites: 200,
    servicesChoisis: ['Sonorisation', 'Traiteur', 'Decoration', 'Chef projet'],
    montantTotal: 1_560_000,
    acompte: 780_000,
    soldeRestant: 780_000,
    statut: StatutReservation.confirme,
    chefProjetAssigne: true,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  OzelEventReservation(
    id: 'OE-002',
    type: TypeEvenement.conference,
    dateEvenement: DateTime.now().add(const Duration(days: 15)),
    lieu: 'Hotel du Lac, Cotonou',
    nbInvites: 80,
    servicesChoisis: ['Sonorisation', 'Traiteur'],
    montantTotal: 432_000,
    acompte: 216_000,
    soldeRestant: 216_000,
    statut: StatutReservation.enAttente,
    chefProjetAssigne: false,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  OzelEventReservation(
    id: 'OE-003',
    type: TypeEvenement.anniversaire,
    dateEvenement: DateTime.now().subtract(const Duration(days: 10)),
    lieu: 'Domicile prive, Akpakpa',
    nbInvites: 50,
    servicesChoisis: ['Decoration', 'Traiteur'],
    montantTotal: 330_000,
    acompte: 165_000,
    soldeRestant: 0,
    statut: StatutReservation.termine,
    chefProjetAssigne: false,
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
  ),
];

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/circuit_model.dart';
import '../../../shared/models/tour_reservation.dart';

/// Commission Ozel Tours : 12% incluse dans le prix affiche.
const double kToursCommission = 0.12;

/// Provider liste circuits
final circuitsProvider = Provider<List<CircuitModel>>((ref) => _mockCircuits);

/// Provider reservations tours
class ToursReservationsNotifier extends Notifier<List<TourReservation>> {
  @override
  List<TourReservation> build() => _mockReservations;

  void addReservation(TourReservation r) {
    state = [r, ...state];
  }
}

final toursReservationsProvider =
    NotifierProvider<ToursReservationsNotifier, List<TourReservation>>(
  ToursReservationsNotifier.new,
);

/// 3 circuits mock
final _mockCircuits = [
  CircuitModel(
    id: 'c1',
    nom: 'Ganvie — Village lacustre',
    destination: 'Ganvie',
    dureeJours: 1,
    prix: 25000,
    guide: 'Kofi Mensah',
    note: 4.8,
    description:
        'Decouvrez Ganvie, la Venise de l\'Afrique. Village construit sur le lac Nokoue, '
        'accessible uniquement en pirogue. Un patrimoine unique au monde.',
    emoji: '🚣',
    programme: [
      'Matin : Depart de Cotonou en pirogue motorisee',
      'Matinee : Visite du village lacustre, rencontre des habitants',
      'Midi : Dejeuner traditionnel sur l\'eau',
      'Apres-midi : Retour a Cotonou',
    ],
    chauffeurInclus: true,
  ),
  CircuitModel(
    id: 'c2',
    nom: 'Ouidah — Route des esclaves',
    destination: 'Ouidah',
    dureeJours: 1,
    prix: 20000,
    guide: 'Adjovi Celestin',
    note: 4.7,
    description:
        'Parcourez la Route des Esclaves, site historique classe UNESCO. '
        'Visitez le Temple des Pythons et la Porte du Non-Retour.',
    emoji: '🏛️',
    programme: [
      'Matin : Depart de Cotonou (1h30 de route)',
      'Matinee : Temple des Pythons, musee d\'histoire',
      'Midi : Dejeuner local',
      'Apres-midi : Route des Esclaves, Porte du Non-Retour',
      'Soir : Retour a Cotonou',
    ],
    chauffeurInclus: true,
  ),
  CircuitModel(
    id: 'c3',
    nom: 'Pendjari — Safari nature',
    destination: 'Pendjari',
    dureeJours: 3,
    prix: 150000,
    guide: 'Moussa Traore',
    note: 4.9,
    description:
        'Safari dans le Parc National de la Pendjari, l\'un des derniers refuges '
        'de la faune sauvage en Afrique de l\'Ouest. Lions, elephants, hippopotames.',
    emoji: '🦁',
    programme: [
      'Jour 1 : Depart Cotonou, arrivee Natitingou, installation lodge',
      'Jour 2 : Safari matin et soir, observation faune sauvage',
      'Jour 3 : Dernier safari matinal, retour Cotonou',
    ],
    chauffeurInclus: true,
  ),
];

/// 2 reservations mock
final _mockReservations = [
  TourReservation(
    id: 'TR-001',
    circuitId: 'c1',
    circuitNom: 'Ganvie — Village lacustre',
    destination: 'Ganvie',
    dateDepart: DateTime.now().add(const Duration(days: 14)),
    nbPersonnes: 2,
    montant: 50000,
    qrCode: 'OZEL-TR-001-GANVIE',
    statut: StatutTourReservation.confirmee,
    guide: 'Kofi Mensah',
  ),
  TourReservation(
    id: 'TR-002',
    circuitId: 'c2',
    circuitNom: 'Ouidah — Route des esclaves',
    destination: 'Ouidah',
    dateDepart: DateTime.now().subtract(const Duration(days: 30)),
    nbPersonnes: 3,
    montant: 60000,
    qrCode: 'OZEL-TR-002-OUIDAH',
    statut: StatutTourReservation.terminee,
    guide: 'Adjovi Celestin',
  ),
];

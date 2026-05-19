import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/hotesse_model.dart';
import '../../../shared/models/hotesse_reservation.dart';

/// Tarifs Ozel Hotesses
abstract final class HotessesTarifs {
  static const double tarifJour = 15000; // 8h
  static const double majorationNuit = 0.50; // +50%
  static const double majorationEN = 5000; // +5000 FCFA/jour
}

/// Calcule le tarif hotesse.
double calculerTarifHotesse({
  required int dureeHeures,
  required bool nuitOuSpeciale,
  required bool langueEN,
}) {
  final nbJours = (dureeHeures / 8).ceil();
  double base = HotessesTarifs.tarifJour * nbJours;
  if (nuitOuSpeciale) base += base * HotessesTarifs.majorationNuit;
  if (langueEN) base += HotessesTarifs.majorationEN * nbJours;
  return base;
}

/// Provider liste hotesses
final hotessesListProvider = Provider<List<HotesseModel>>((ref) => _mockHotesses);

/// Provider reservations hotesses
class HotessesReservationsNotifier extends Notifier<List<HotesseReservation>> {
  @override
  List<HotesseReservation> build() => _mockReservations;

  void addReservation(HotesseReservation r) {
    state = [r, ...state];
  }
}

final hotessesReservationsProvider =
    NotifierProvider<HotessesReservationsNotifier, List<HotesseReservation>>(
  HotessesReservationsNotifier.new,
);

/// 5 hotesses mock
final _mockHotesses = [
  const HotesseModel(
    id: 'h1',
    prenom: 'Aminata',
    taille: '1m72',
    langues: ['FR', 'EN'],
    experience: 5,
    note: 4.8,
    tarif: 15000,
    tenues: ['Formelle', 'Traditionnelle'],
  ),
  const HotesseModel(
    id: 'h2',
    prenom: 'Clarisse',
    taille: '1m68',
    langues: ['FR'],
    experience: 3,
    note: 4.6,
    tarif: 15000,
    tenues: ['Formelle'],
  ),
  const HotesseModel(
    id: 'h3',
    prenom: 'Fatoumata',
    taille: '1m75',
    langues: ['FR', 'EN'],
    experience: 7,
    note: 4.9,
    tarif: 15000,
    tenues: ['Formelle', 'Traditionnelle', 'Cocktail'],
  ),
  const HotesseModel(
    id: 'h4',
    prenom: 'Roseline',
    taille: '1m65',
    langues: ['FR'],
    experience: 2,
    note: 4.4,
    tarif: 15000,
    tenues: ['Traditionnelle'],
  ),
  const HotesseModel(
    id: 'h5',
    prenom: 'Nadege',
    taille: '1m70',
    langues: ['FR', 'EN'],
    experience: 4,
    note: 4.7,
    tarif: 15000,
    tenues: ['Formelle', 'Cocktail'],
  ),
];

/// 2 reservations mock
final _mockReservations = [
  HotesseReservation(
    id: 'HR-001',
    hotesseId: 'h1',
    hotessePrenom: 'Aminata',
    dateDebut: DateTime.now().add(const Duration(days: 7)),
    dureeHeures: 8,
    tarif: 20000,
    statut: StatutHotesseReservation.confirmee,
    typeEvenement: 'Conference',
  ),
  HotesseReservation(
    id: 'HR-002',
    hotesseId: 'h3',
    hotessePrenom: 'Fatoumata',
    dateDebut: DateTime.now().subtract(const Duration(days: 5)),
    dureeHeures: 16,
    tarif: 45000,
    statut: StatutHotesseReservation.terminee,
    typeEvenement: 'Mariage',
  ),
];
